package com.appseparacao.service;
import com.appseparacao.model.LogProdutividade;
import com.appseparacao.repository.LogProdutividadeRepository;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProdutividadeService {

	@Autowired
	private LogProdutividadeRepository repository;
	
	public LogProdutividade iniciarTarefa(String nome, String tipo) {
		LogProdutividade log = new LogProdutividade();
		log.setColaboradorNome(nome);
		log.setTipoAtividade(tipo);
		log.setDataInicio(LocalDateTime.now());
		return repository.save(log);
		
	}
	
	public LogProdutividade finalizarTarefa(long id, Integer qtd) {
		LogProdutividade log = repository.findById(id).orElseThrow();
		log.setDataFim(LocalDateTime.now());
		log.setQuantidadeItens(qtd);
		return repository.save(log);
		
		
	}
}
