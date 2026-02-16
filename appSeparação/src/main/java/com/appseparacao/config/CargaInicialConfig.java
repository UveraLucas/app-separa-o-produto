package com.appseparacao.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.appseparacao.model.Usuario;
import com.appseparacao.model.Pedido;
import com.appseparacao.repository.UsuarioRepository;
import com.appseparacao.repository.PedidoRepository;

@Configuration
public class CargaInicialConfig {

    @Bean
    CommandLineRunner carregarDados(UsuarioRepository uRepo, PedidoRepository pRepo) {
        return args -> {
            // Criando Usuário de Teste (Login ERP)
            if (uRepo.count() == 0) {
                Usuario u = new Usuario();
                u.setNome("Mestre Desenvolvedor");
                u.setUsuarioErp("mestre"); // Seu login de teste
                u.setCargo("SEPARADOR");
                uRepo.save(u);
                System.out.println(">>> Usuário de teste criado: mestre123");
            }

            // Criando Pedidos de Teste (Simulando o ERP)
            if (pRepo.count() == 0) {
                Pedido p1 = new Pedido();
                p1.setNumeroErp("ERP-2026-001");
                p1.setCliente("Logística Brasil S/A");
                p1.setStatus("PENDENTE");
                pRepo.save(p1);

                Pedido p2 = new Pedido();
                p2.setNumeroErp("ERP-2026-002");
                p2.setCliente("Distribuidora PopOS");
                p2.setStatus("PENDENTE");
                pRepo.save(p2);
                
                System.out.println(">>> Pedidos de teste criados com sucesso!");
            }
        };
    }
}