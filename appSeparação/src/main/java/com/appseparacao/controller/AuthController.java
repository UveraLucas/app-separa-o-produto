package com.appseparacao.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.appseparacao.repository.UsuarioRepository;
import com.appseparacao.model.Usuario;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private UsuarioRepository usuarioRepo;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestParam String matricula, @RequestParam String senha) {
        // CORREÇÃO: Passamos 'matricula' (o que veio do Postman) para buscar no banco
        Optional<Usuario> usuario = usuarioRepo.findByUsuarioErpAndSenha(matricula, senha);
        
        if (usuario.isPresent()) {
            return ResponseEntity.ok(usuario.get());
        }
        return ResponseEntity.status(401).body("Credenciais inválidas");
    }
}
