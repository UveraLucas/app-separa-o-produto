package com.appseparacao.controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.appseparacao.service.ProdutividadeService;
import com.appseparacao.model.LogProdutividade;

@RestController
@RequestMapping("/api/producao")
public class ProducaoController {

	@Autowired
	private ProdutividadeService service;
	
	@PostMapping("/iniciar")
	public ResponseEntity<LogProdutividade> iniciar(@RequestParam String nome, @RequestParam String tipo) {
        return ResponseEntity.ok(service.iniciarTarefa(nome, tipo));
    }

    @PostMapping("/finalizar/{id}")
    public ResponseEntity<LogProdutividade> finalizar(@PathVariable Long id, @RequestParam Integer qtd) {
        return ResponseEntity.ok(service.finalizarTarefa(id, qtd));
    }
}
