package com.appseparacao.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.appseparacao.model.Pedido;
import java.util.List;
import java.util.Optional;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    // Para listar o que o colaborador ainda precisa separar
    List<Pedido> findByStatusIn(List<String> statuses);

    // Para buscar um pedido específico vindo do ERP
    Optional<Pedido> findByNumeroErp(String numeroErp);
}