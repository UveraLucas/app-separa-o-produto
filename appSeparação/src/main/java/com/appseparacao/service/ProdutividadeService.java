package com.appseparacao.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.appseparacao.model.*;
import com.appseparacao.repository.*;
import java.time.LocalDateTime;
import com.appseparacao.model.Pedido;
import com.appseparacao.repository.PedidoRepository;

@Service
public class ProdutividadeService {

    @Autowired
    private LogProdutividadeRepository logRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PedidoRepository pedidoRepository;

    // Inicia o cronômetro da produtividade vinculando o usuário e o pedido real

    public LogProdutividade iniciarTarefa(String UsuarioErp, String numeroPedidoErp) {
        
        // 1. Busca Usuário e Pedido (igual antes)
        Usuario usuario = usuarioRepository.findByUsuarioErp(UsuarioErp)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Pedido pedido = pedidoRepository.findByNumeroErp(numeroPedidoErp)
                .orElseThrow(() -> new RuntimeException("Pedido não localizado"));
        
        // 2. LÓGICA NOVA: Define a atividade baseada no estado atual do pedido
        String novaAtividade = "";
        
        if ("PENDENTE".equals(pedido.getStatus())) {
            // Começando a Separação
            pedido.setStatus("EM_SEPARACAO");
            novaAtividade = "SEPARACAO";
            
        } else if ("AGUARDANDO_CONFERENCIA".equals(pedido.getStatus())) {
            // Começando a Conferência
            pedido.setStatus("EM_CONFERENCIA");
            novaAtividade = "CONFERENCIA";
            
        } else {
            // Bloqueia se tentar pegar um pedido já concluído ou em uso
            throw new RuntimeException("Este pedido não está disponível para início (Status atual: " + pedido.getStatus() + ")");
        }
        
        pedidoRepository.save(pedido);

        // 3. Cria o Log com a atividade correta
        LogProdutividade log = new LogProdutividade();
        log.setUsuario(usuario);
        log.setPedido(pedido);
        log.setDataInicio(LocalDateTime.now());
        log.setTipoAtividade(novaAtividade); // Agora grava se é SEPARACAO ou CONFERENCIA

        return logRepository.save(log);
    }
    
 // Novo método para bipar produto
    public ItemPedido biparProduto(Long pedidoId, String codigoBarras) {
        Pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));

        // Procura o item na lista do pedido pelo código de barras
        ItemPedido itemEncontrado = pedido.getItens().stream()
                .filter(item -> item.getCodigoBarras().equals(codigoBarras))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Produto não pertence a este pedido!"));

        // Verifica se já separou tudo
        if (itemEncontrado.getQtdSeparada() >= itemEncontrado.getQtdSolicitada()) {
            throw new RuntimeException("Este item já foi totalmente separado! (Excesso)");
        }

        // Incrementa e Salva (Na verdade, ao salvar o pedido, o item salva junto por causa do Cascade)
        itemEncontrado.setQtdSeparada(itemEncontrado.getQtdSeparada() + 1);
        pedidoRepository.save(pedido); 
        
        return itemEncontrado;
    }
    
	// No ProdutividadeService.java

	public ItemPedido realizarCorte(Long pedidoId, String codigoBarras) {
	    Pedido pedido = pedidoRepository.findById(pedidoId)
	            .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));

	    ItemPedido item = pedido.getItens().stream()
	            .filter(i -> i.getCodigoBarras().equals(codigoBarras))
	            .findFirst()
	            .orElseThrow(() -> new RuntimeException("Produto não encontrado neste pedido"));

	    // LÓGICA DO CORTE:
	    // 1. Zera a quantidade separada (conforme sua regra)
	    item.setQtdSeparada(0);
	    // 2. Marca como cortado
	    item.setItemCortado(true);
	    
	    // Salva o pedido (o Cascade salva o item)
	    pedidoRepository.save(pedido);

	    return item;
	}

	public LogProdutividade finalizarTarefa(Long logId, Integer qtdItens) {
	    LogProdutividade log = logRepository.findById(logId)
	            .orElseThrow(() -> new RuntimeException("Log não encontrado"));

	    log.setDataFim(LocalDateTime.now());
	    log.setQuantidadeItens(qtdItens); // Grava quantos bips o usuário deu nesta etapa

	    Pedido pedido = log.getPedido();
	    
	    // --- FLUXO DE STATUS ---
	    
	    if ("EM_SEPARACAO".equals(pedido.getStatus())) {
	        // Fim da Separação: Apenas move para conferência.
	        // Mesmo que tenha itens zerados, não corta nada ainda. 
	        // O conferente terá a chance de tentar achar.
	        pedido.setStatus("AGUARDANDO_CONFERENCIA");
	        
	    } else if ("EM_CONFERENCIA".equals(pedido.getStatus())) {
	        // Fim da Conferência: AQUI ACONTECE O CORTE OFICIAL
	        
	        for (ItemPedido item : pedido.getItens()) {
	            // Se separou MENOS do que o solicitado...
	            if (item.getQtdSeparada() < item.getQtdSolicitada()) {
	                // ...Marca como Cortado oficialmente agora.
	                item.setItemCortado(true);
	                
	                // Opcional: Se quiser garantir que fique zerado o que faltou,
	                // mas geralmente mantemos o parcial (ex: pediu 10, achou 8, corta 2).
	                // Se a regra for "ou tudo ou nada", você zeraria aqui.
	            }
	        }
	        
	        pedido.setStatus("CONCLUIDO");
	    }

	    pedidoRepository.save(pedido);
	    return logRepository.save(log);
	}
}