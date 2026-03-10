package com.appseparacao.model;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import jakarta.persistence.OneToMany;
import jakarta.persistence.CascadeType;


@Entity
@Data
public class Pedido {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;
	
	@Column(nullable = false, unique = true)
	private String numeroErp;
	
	private String codigoCliente;
	private String nomeCliente;
	private String cidade;
	private String estado;
	
	@Column(nullable = false)
	private String status; //pendente, separação, concluido
	
	private LocalDateTime dataCriacao;
	
	@PrePersist
	protected void onCreate() {
		this.dataCriacao = LocalDateTime.now();
		if(this.status == null) this.status = "PENDENTE";
	}
	
	@OneToMany(mappedBy = "pedido", cascade = CascadeType.ALL)
	private List<ItemPedido> itens;

	//Getter e Setter
	public List<ItemPedido> getItens() { return itens; }
	public void setItens(List<ItemPedido> itens) { this.itens = itens; }

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


	public String getCodigoCliente() {
		return codigoCliente;
	}
	public void setCodigoCliente(String codigoCliente) {
		this.codigoCliente = codigoCliente;
	}
	public String getNomeCliente() {
		return nomeCliente;
	}
	public void setNomeCliente(String nomeCliente) {
		this.nomeCliente = nomeCliente;
	}
	public String getCidade() {
		return cidade;
	}
	public void setCidade(String cidade) {
		this.cidade = cidade;
	}
	public String getEstado() {
		return estado;
	}
	public void setEstado(String estado) {
		this.estado = estado;
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

