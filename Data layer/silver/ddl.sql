CREATE SCHEMA IF NOT EXISTS cat_db;

DROP TABLE IF EXISTS ACIDENTE;

CREATE TABLE ACIDENTE (
    agente_causador_acidente TEXT,
    data_acidente_referencia DATE,
    cbo_codigo_descricao TEXT,
    cid_10 TEXT,
    cnae_empregador TEXT,
    municipio_empregador TEXT,
    natureza_lesao TEXT,
    parte_corpo_atingida TEXT,
    sexo TEXT,
    tipo_acidente TEXT,
    uf_municipio_acidente TEXT,
    uf_municipio_empregador TEXT,
    data_nascimento DATE,
    data_emissao_cat DATE
);