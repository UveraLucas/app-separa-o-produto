package com.appseparacao.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.appseparacao.model.LogProdutividade;

public interface LogProdutividadeRepository extends JpaRepository<LogProdutividade, Long> {
    // Aqui você pode criar métodos customizados futuramente, como buscar por colaborador
}
