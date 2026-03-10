package com.appseparacao.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.appseparacao.model.*;
import com.appseparacao.repository.*;
import java.time.LocalDateTime;

@Service
public class ProdutividadeService {

    @Autowired
    private LogProdutividadeRepository logRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PedidoRepository pedidoRepository;

    // --- 1. INICIAR OU RETOMAR A TAREFA (CORREÇÃO DO BUG) ---
    public LogProdutividade iniciarTarefa(String UsuarioErp, String numeroPedidoErp) {
        
        Usuario usuario = usuarioRepository.findByUsuarioErp(UsuarioErp)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Pedido pedido = pedidoRepository.findByNumeroErp(numeroPedidoErp)
                .orElseThrow(() -> new RuntimeException("Pedido não localizado"));
        
        // CORREÇÃO: SE JÁ ESTIVER EM ANDAMENTO, DEIXA ENTRAR!
        if ("EM_SEPARACAO".equals(pedido.getStatus()) || "EM_SEPARAÇÃO".equals(pedido.getStatus()) || "EM_CONFERENCIA".equals(pedido.getStatus())) {
            
            // Busca o log antigo que ficou pausado
            LogProdutividade logExistente = logRepository.findFirstByPedidoAndUsuarioOrderByDataInicioDesc(pedido, usuario);
            
            if (logExistente != null && logExistente.getDataFim() == null) {
                return logExistente; // Retorna o log antigo perfeitamente!
            } else {
                // Se por acaso não achar, cria um log de "Retomada"
                LogProdutividade logNovo = new LogProdutividade();
                logNovo.setUsuario(usuario);
                logNovo.setPedido(pedido);
                logNovo.setDataInicio(LocalDateTime.now());
                logNovo.setTipoAtividade("RETOMADA_" + pedido.getStatus());
                return logRepository.save(logNovo);
            }
        }

        // SE FOR PENDENTE OU AGUARDANDO CONFERÊNCIA (Segue o fluxo normal)
        String novaAtividade = "";
        
        if ("PENDENTE".equals(pedido.getStatus())) {
            pedido.setStatus("EM_SEPARACAO");
            novaAtividade = "SEPARACAO";
        } else if ("AGUARDANDO_CONFERENCIA".equals(pedido.getStatus())) {
            pedido.setStatus("EM_CONFERENCIA");
            novaAtividade = "CONFERENCIA";
        } else {
            throw new RuntimeException("Este pedido não está disponível para início (Status atual: " + pedido.getStatus() + ")");
        }
        
        pedidoRepository.save(pedido);

        LogProdutividade log = new LogProdutividade();
        log.setUsuario(usuario);
        log.setPedido(pedido);
        log.setDataInicio(LocalDateTime.now());
        log.setTipoAtividade(novaAtividade); 

        return logRepository.save(log);
    }
    
    // --- 2. BIPAR PRODUTO (MANTIDO O SEU CÓDIGO) ---
    public ItemPedido biparProduto(Long pedidoId, String codigoBarras) {
        Pedido pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));

        ItemPedido itemEncontrado = pedido.getItens().stream()
                .filter(item -> item.getCodigoBarras().equals(codigoBarras))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Produto não pertence a este pedido!"));

        if (itemEncontrado.getQtdSeparada() >= itemEncontrado.getQtdSolicitada()) {
            throw new RuntimeException("Este item já foi totalmente separado! (Excesso)");
        }

        itemEncontrado.setQtdSeparada(itemEncontrado.getQtdSeparada() + 1);
        pedidoRepository.save(pedido); 
        return itemEncontrado;
    }
    
    // --- 3. FINALIZAR TAREFA E CALCULAR VALOR R$ (NOVIDADE) ---
    public LogProdutividade finalizarTarefa(Long logId, Integer qtdItens) {
        LogProdutividade log = logRepository.findById(logId)
                .orElseThrow(() -> new RuntimeException("Log não encontrado"));

        log.setDataFim(LocalDateTime.now());
        log.setQuantidadeItens(qtdItens); 
        
        Pedido pedido = log.getPedido();
        
        // NOVIDADE: CALCULADORA DE PRODUTIVIDADE FINANCEIRA
        double valorDaTarefa = 0.0;
        for (ItemPedido item : pedido.getItens()) {
            if (item.getPrecoUnitario() != null) {
                // Soma (Quantidade que o operador bipou * Preço da Peça)
                valorDaTarefa += (item.getQtdSeparada() * item.getPrecoUnitario());
            }
        }
        log.setValorTotalProcessado(valorDaTarefa); // Salva os "R$" neste log!

        // --- FLUXO DE STATUS ---
        if ("EM_SEPARACAO".equals(pedido.getStatus()) || "EM_SEPARAÇÃO".equals(pedido.getStatus())) {
            pedido.setStatus("AGUARDANDO_CONFERENCIA");
        } else if ("EM_CONFERENCIA".equals(pedido.getStatus())) {
            for (ItemPedido item : pedido.getItens()) {
                if (item.getQtdSeparada() < item.getQtdSolicitada()) {
                    item.setItemCortado(true);
                }
            }
            pedido.setStatus("CONCLUIDO");
        }

        pedidoRepository.save(pedido);
        return logRepository.save(log);
    }

	public ItemPedido realizarCorte(Long pedidoId, String codigoBarras) {
		// TODO Auto-generated method stub
		return null;
	}

	}
