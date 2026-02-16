package com.appseparacao.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.appseparacao.model.Usuario;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Busca o usuário pelo login registrado no ERP
    Optional<Usuario> findByUsuarioErp(String usuarioErp);
}