package com.appseparacao.model;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class Pedido {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;
	
	@Column(nullable = false, unique = true)
	private String numeroErp;
	
	private String cliente;
	
	@Column(nullable = false)
	private String status; //pendente, separação, concluido
	
	private LocalDateTime dataCriacao;
	
	@PrePersist
	protected void onCreate() {
		this.dataCriacao = LocalDateTime.now();
		if(this.status == null) this.status = "PENDENTE";
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getNumeroErp() {
		return numeroErp;
	}

	public void setNumeroErp(String numeroErp) {
		this.numeroErp = numeroErp;
	}

	public String getCliente() {
		return cliente;
	}

	public void setCliente(String cliente) {
		this.cliente = cliente;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public LocalDateTime getDataCriacao() {
		return dataCriacao;
	}

	public void setDataCriacao(LocalDateTime dataCriacao) {
		this.dataCriacao = dataCriacao;
	}
	
	
}
