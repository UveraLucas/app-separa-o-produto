package com.appseparacao.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore; // Importante para não dar loop infinito no JSON

@Entity
public class ItemPedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String codigoBarras; // O código que será bipado (EAN)
    private String descricao;    // Ex: "Teclado USB"
    private Integer qtdSolicitada; // O que o ERP pediu (Ex: 10)
    private Integer qtdSeparada = 0; // O que o separador já bipou (Começa com 0)

    @ManyToOne
    @JoinColumn(name = "pedido_id")
    @JsonIgnore // O item sabe quem é o pedido, mas ao listar o pedido, não queremos repetir o pedido dentro do item
    private Pedido pedido;
   

    @Column(columnDefinition = "boolean default false")
    private Boolean itemCortado = false; // Novo campo

    // Getters e Setters
    public Boolean getItemCortado() { return itemCortado; }
    public void setItemCortado(Boolean itemCortado) { this.itemCortado = itemCortado; }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCodigoBarras() { return codigoBarras; }
    public void setCodigoBarras(String codigoBarras) { this.codigoBarras = codigoBarras; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public Integer getQtdSolicitada() { return qtdSolicitada; }
    public void setQtdSolicitada(Integer qtdSolicitada) { this.qtdSolicitada = qtdSolicitada; }
    public Integer getQtdSeparada() { return qtdSeparada; }
    public void setQtdSeparada(Integer qtdSeparada) { this.qtdSeparada = qtdSeparada; }
    public Pedido getPedido() { return pedido; }
    public void setPedido(Pedido pedido) { this.pedido = pedido; }
}