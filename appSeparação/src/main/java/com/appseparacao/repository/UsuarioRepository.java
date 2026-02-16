package com.appseparacao.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.appseparacao.model.Usuario;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Busca usuário validando login e senha
	Optional<Usuario> findByUsuarioErpAndSenha(String usuarioErp, String senha);
    
 // Método para buscar pelo Login (Corrige o erro da sua tela)
    Optional<Usuario> findByUsuarioErp(String usuarioErp);
}