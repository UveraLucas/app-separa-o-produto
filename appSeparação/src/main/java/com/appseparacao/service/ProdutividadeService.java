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

    // Inicia o cronômetro da produtividade vinculando o usuário e o pedido real
    public LogProdutividade iniciarTarefa(String usuarioErp, String numeroPedidoErp) {
        
        // 1. Busca o usuário pelo login do ERP
        Usuario usuario = usuarioRepository.findByUsuarioErp(usuarioErp)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado no sistema ERP"));

        // 2. Busca o pedido e altera o status para indicar que está em separação
        Pedido pedido = pedidoRepository.findByNumeroErp(numeroPedidoErp)
                .orElseThrow(() -> new RuntimeException("Pedido não localizado"));
        
        pedido.setStatus("EM_SEPARACAO");
        pedidoRepository.save(pedido);

        // 3. Registra o início do log
        LogProdutividade log = new LogProdutividade();
        log.setUsuario(usuario);
        log.setPedido(pedido);
        log.setDataInicio(LocalDateTime.now());
        log.setTipoAtividade(usuario.getCargo()); // Define se é SEPARACAO ou COLETA baseado no perfil

        return logRepository.save(log);
    }

    // Finaliza a tarefa, calcula os itens e libera o pedido
    public LogProdutividade finalizarTarefa(Long logId, Integer qtdItens) {
        LogProdutividade log = logRepository.findById(logId)
                .orElseThrow(() -> new RuntimeException("Log de produtividade não encontrado"));

        log.setDataFim(LocalDateTime.now());
        log.setQuantidadeItens(qtdItens);

        // Atualiza o pedido para concluído
        Pedido pedido = log.getPedido();
        pedido.setStatus("CONCLUIDO");
        pedidoRepository.save(pedido);

        return logRepository.save(log);
    }
}