package com.appseparacao.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.appseparacao.model.LogProdutividade;
import com.appseparacao.model.Pedido;
import com.appseparacao.model.Usuario;

public interface LogProdutividadeRepository extends JpaRepository<LogProdutividade, Long> {
    
    // BUSCA O ÚLTIMO LOG ABERTO DESSE PEDIDO PARA ESSE USUÁRIO
    LogProdutividade findFirstByPedidoAndUsuarioOrderByDataInicioDesc(Pedido pedido, Usuario usuario);
}