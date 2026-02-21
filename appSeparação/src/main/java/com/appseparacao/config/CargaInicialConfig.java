package com.appseparacao.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.appseparacao.model.Usuario;
import com.appseparacao.model.ItemPedido;
import com.appseparacao.model.Pedido;
import com.appseparacao.repository.UsuarioRepository;
import com.appseparacao.repository.PedidoRepository;

import java.util.Arrays;
import java.util.Optional;

@Configuration
public class CargaInicialConfig {

    @Bean
    CommandLineRunner carregarDados(UsuarioRepository uRepo, PedidoRepository pRepo) {
        return args -> {
            // --- 1. CONFIGURAÇÃO DO USUÁRIO ---
            Optional<Usuario> usuarioExistente = uRepo.findByUsuarioErp("mestre");

            if (usuarioExistente.isPresent()) {
                Usuario u = usuarioExistente.get();
                u.setSenha("123456");
                uRepo.save(u);
                System.out.println(">>> Senha do utilizador 'mestre' garantida para 123456!");
            } else {
                Usuario u1 = new Usuario();
                u1.setNome("Mestre do WMS");
                u1.setCargo("Separador Senior");
                u1.setUsuarioErp("mestre");
                u1.setSenha("123456");
                uRepo.save(u1);
                System.out.println(">>> Utilizador 'mestre' criado com sucesso!");
            }

            // --- 2. CONFIGURAÇÃO DOS PEDIDOS DE TESTE ---
            
            // PEDIDO 001
// --- 2. CONFIGURAÇÃO DOS PEDIDOS DE TESTE ---
            
            // PEDIDO 001
            Optional<Pedido> p1Existente = pRepo.findByNumeroErp("ERP-2026-001");
            if (p1Existente.isEmpty()) {
                // Se não existe, cria do zero
                Pedido p1 = new Pedido();
                p1.setNumeroErp("ERP-2026-001");
                p1.setCliente("Logística Brasil S/A");
                p1.setStatus("PENDENTE");

                ItemPedido i1 = new ItemPedido();
                i1.setDescricao("Mouse Sem Fio Logitech");
                i1.setCodigoBarras("789123456");
                i1.setQtdSolicitada(5);
                i1.setPedido(p1);

                ItemPedido i2 = new ItemPedido();
                i2.setDescricao("Teclado Mecânico");
                i2.setCodigoBarras("789999999");
                i2.setQtdSolicitada(2);
                i2.setPedido(p1);

                p1.setItens(Arrays.asList(i1, i2));
                pRepo.save(p1);
            } else {
                // SE JÁ EXISTE, FORÇA O STATUS DE VOLTA PARA PENDENTE PARA PODERMOS TESTAR
                Pedido p1 = p1Existente.get();
                p1.setStatus("PENDENTE");
                pRepo.save(p1);
            }

            // NOVO PEDIDO 003
            Optional<Pedido> p3Existente = pRepo.findByNumeroErp("ERP-2026-003");
            if (p3Existente.isEmpty()) {
                Pedido p3 = new Pedido();
                p3.setNumeroErp("ERP-2026-003");
                p3.setCliente("Tech Corp LTDA");
                p3.setStatus("PENDENTE");

                ItemPedido i3 = new ItemPedido();
                i3.setDescricao("Monitor Ultrawide 29 LG");
                i3.setCodigoBarras("111222333"); 
                i3.setQtdSolicitada(1);
                i3.setPedido(p3);

                ItemPedido i4 = new ItemPedido();
                i4.setDescricao("Headset Gamer HyperX");
                i4.setCodigoBarras("444555666"); 
                i4.setQtdSolicitada(3);
                i4.setPedido(p3);

                p3.setItens(Arrays.asList(i3, i4));
                pRepo.save(p3);
            } else {
                 // SE JÁ EXISTE, FORÇA O STATUS DE VOLTA PARA PENDENTE
                Pedido p3 = p3Existente.get();
                p3.setStatus("PENDENTE");
                pRepo.save(p3);
            }
        }; 
    }
}