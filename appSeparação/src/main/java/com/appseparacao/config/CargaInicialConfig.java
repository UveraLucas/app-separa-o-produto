package com.appseparacao.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.appseparacao.model.Usuario;
import com.appseparacao.model.ItemPedido;
import com.appseparacao.model.Pedido;
import com.appseparacao.repository.UsuarioRepository;
import com.appseparacao.repository.PedidoRepository;

import java.util.Arrays; // Importante para criar a lista de itens
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
                System.out.println(">>> Senha do usuário 'mestre' atualizada para 123456!");
            } else {
                Usuario u1 = new Usuario();
                u1.setNome("Mestre do WMS");
                u1.setCargo("Separador Senior");
                u1.setUsuarioErp("mestre");
                u1.setSenha("123456");
                uRepo.save(u1);
                System.out.println(">>> Usuário 'mestre' criado com sucesso!");
            }

            // --- 2. CONFIGURAÇÃO DOS PEDIDOS ---
            if (pRepo.count() == 0) {
                
                // PEDIDO 1: Com Itens (Mouse e Teclado)
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

                // Usa Arrays.asList para evitar erros de versão do Java
                p1.setItens(Arrays.asList(i1, i2));
                
                pRepo.save(p1);
                System.out.println(">>> Pedido 001 criado com ITENS!");

                // PEDIDO 2: Sem Itens (Para teste futuro)
                Pedido p2 = new Pedido();
                p2.setNumeroErp("ERP-2026-002");
                p2.setCliente("Distribuidora PopOS");
                p2.setStatus("PENDENTE");
                
                pRepo.save(p2);
                System.out.println(">>> Pedido 002 criado!");
            }
        }; // <--- AQUI É O FIM DA EXECUÇÃO (O return fecha aqui)
    }
}