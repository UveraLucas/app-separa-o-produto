package com.appseparacao.controller;

import com.appseparacao.model.Pedido;
import com.appseparacao.repository.PedidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController // <-- ISSO É OBRIGATÓRIO (Avisa o Java que é um controlador)
@RequestMapping("/api/pedidos") // <-- ISSO DEFINE A BASE DA URL
@CrossOrigin("*") 
public class PedidoController {

    @Autowired
    private PedidoRepository pedidoRepository;

    @GetMapping("/listar/{status}") // <-- ISSO COMPLETA A URL
    public List<Pedido> listarPorStatus(@PathVariable String status) {
        return pedidoRepository.findByStatus(status);
    }
    
 // Adicione ou substitua este método dentro do seu PedidoController
    @PutMapping("/{id}/status")
    public ResponseEntity<Pedido> atualizarStatus(
            @PathVariable Long id, 
            @RequestParam("status") String status) { // <-- O NOME EXATO AQUI É 'status'
        
        Optional<Pedido> pedidoExistente = pedidoRepository.findById(id);
        
        if (pedidoExistente.isPresent()) {
            Pedido pedido = pedidoExistente.get();
            pedido.setStatus(status);
            pedidoRepository.save(pedido);
            return ResponseEntity.ok(pedido);
        }
        
        return ResponseEntity.notFound().build();
    }
}