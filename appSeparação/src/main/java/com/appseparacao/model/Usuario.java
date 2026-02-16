package com.appseparacao.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Usuario {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;
	
	@Column(nullable = false, unique =true)
	private String usuarioErp;
	
	@Column(nullable = false)
	private String nome;
	
	
	public String getUsuarioErp() {
		return usuarioErp;
	}

	public void setUsuarioErp(String usuarioErp) {
		this.usuarioErp = usuarioErp;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}


	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getCargo() {
		return cargo;
	}

	public void setCargo(String cargo) {
		this.cargo = cargo;
	}

	@Column(nullable = false)
	private String cargo;
	
}
