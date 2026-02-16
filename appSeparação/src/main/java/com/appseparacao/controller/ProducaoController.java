package com.appseparacao.controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.appseparacao.service.ProdutividadeService;
import com.appseparacao.model.ItemPedido;
import com.appseparacao.model.LogProdutividade;


@RestController
@RequestMapping("/api/producao")
public class ProducaoController {

	@Autowired
	private ProdutividadeService service;
	
	@PostMapping("/iniciar")
	public ResponseEntity<LogProdutividade> iniciar(
		    @RequestParam String Usuario_erp, 
		    @RequestParam String numeroPedido) {
		    return ResponseEntity.ok(service.iniciarTarefa(Usuario_erp, numeroPedido));
	}
	
	@PostMapping("/{pedidoId}/bipar")
	public ResponseEntity<?> bipar(@PathVariable Long pedidoId, @RequestParam String codigoBarras) {
	    try {
	        ItemPedido itemAtualizado = service.biparProduto(pedidoId, codigoBarras);
	        return ResponseEntity.ok(itemAtualizado);
	    } catch (RuntimeException e) {
	        // Retorna erro 400 (Bad Request) com a mensagem (ex: Produto não pertence ao pedido)
	        return ResponseEntity.badRequest().body(e.getMessage());
	    }
	}
	
	// No ProducaoController.java

	@PostMapping("/{pedidoId}/corte")
	public ResponseEntity<?> registrarCorte(@PathVariable Long pedidoId, @RequestParam String codigoBarras) {
	    try {
	        ItemPedido item = service.realizarCorte(pedidoId, codigoBarras);
	        return ResponseEntity.ok(item);
	    } catch (RuntimeException e) {
	        return ResponseEntity.badRequest().body(e.getMessage());
	    }
	}

    @PostMapping("/finalizar/{id}")
    public ResponseEntity<LogProdutividade> finalizar(@PathVariable Long id, @RequestParam Integer qtd) {
        return ResponseEntity.ok(service.finalizarTarefa(id, qtd));
    }
}
