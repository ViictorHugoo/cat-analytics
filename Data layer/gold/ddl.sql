CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_tempo CASCADE;
CREATE TABLE gold.dim_tempo (
    srk_temp BIGSERIAL PRIMARY KEY,
    chv_tempo_org DATE NOT NULL UNIQUE,
    dia INTEGER,
    mes INTEGER,
    nome_mes VARCHAR(50),
    trimestre INTEGER,
    ano INTEGER,
    dia_semana INTEGER,
    is_fim_semana BOOLEAN
);

DROP TABLE IF EXISTS gold.dim_cbo CASCADE;
CREATE TABLE gold.dim_cbo (
    srk_cbo BIGSERIAL PRIMARY KEY,
    chv_cbo_org TEXT NOT NULL UNIQUE,
    codigo TEXT,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_municipio CASCADE;
CREATE TABLE gold.dim_municipio (
    srk_munic BIGSERIAL PRIMARY KEY,
    chv_municipio_org TEXT NOT NULL UNIQUE,
    nome TEXT,
    uf TEXT
);

DROP TABLE IF EXISTS gold.dim_cnae CASCADE;
CREATE TABLE gold.dim_cnae (
    srk_cnae BIGSERIAL PRIMARY KEY,
    chv_cnae_org BIGINT NOT NULL UNIQUE,
    codigo BIGINT,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_tipo_acidente CASCADE;
CREATE TABLE gold.dim_tipo_acidente (
    srk_tp_acdt BIGSERIAL PRIMARY KEY,
    chv_tipo_acidente_org TEXT NOT NULL UNIQUE,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_lesao CASCADE;
CREATE TABLE gold.dim_lesao (
    srk_lesao BIGSERIAL PRIMARY KEY,
    chv_lesao_org TEXT NOT NULL UNIQUE,
    natureza_lesao TEXT,
    parte_corpo_atingida TEXT
);

DROP TABLE IF EXISTS gold.dim_agente_causador CASCADE;
CREATE TABLE gold.dim_agente_causador (
    srk_agnt_csdr BIGSERIAL PRIMARY KEY,
    chv_agente_causador_org TEXT NOT NULL UNIQUE,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_cid10 CASCADE;
CREATE TABLE gold.dim_cid10 (
    srk_cid10 BIGSERIAL PRIMARY KEY,
    chv_cid10_org TEXT NOT NULL UNIQUE,
    codigo TEXT,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_trabalhador CASCADE;
CREATE TABLE gold.dim_trabalhador (
    srk_trab BIGSERIAL PRIMARY KEY,
    chv_trabalhador_org TEXT NOT NULL UNIQUE,
    sexo TEXT,
    srk_cbo TEXT,
    srk_temp_nasc DATE
);

DROP TABLE IF EXISTS gold.dim_empregador CASCADE;
CREATE TABLE gold.dim_empregador (
    srk_empreg BIGSERIAL PRIMARY KEY,
    chv_empregador_org TEXT NOT NULL UNIQUE,
    srk_cnae BIGINT,
    srk_munic TEXT
);

DROP TABLE IF EXISTS gold.fato_acidente_trabalho CASCADE;
CREATE TABLE gold.fato_acidente_trabalho (
    srk_fato BIGSERIAL PRIMARY KEY,
    chv_cat_org TEXT NOT NULL,
    
    srk_temp_acdt BIGINT REFERENCES gold.dim_tempo(srk_temp),
    srk_temp_emss BIGINT REFERENCES gold.dim_tempo(srk_temp),
    srk_temp_nasc BIGINT REFERENCES gold.dim_tempo(srk_temp),
    
    srk_trab BIGINT REFERENCES gold.dim_trabalhador(srk_trab),
    srk_cbo BIGINT REFERENCES gold.dim_cbo(srk_cbo),
    srk_empreg BIGINT REFERENCES gold.dim_empregador(srk_empreg),
    srk_cnae BIGINT REFERENCES gold.dim_cnae(srk_cnae),
    
    srk_munic_acdt BIGINT REFERENCES gold.dim_municipio(srk_munic),
    srk_munic_empreg BIGINT REFERENCES gold.dim_municipio(srk_munic),
    
    srk_tp_acdt BIGINT REFERENCES gold.dim_tipo_acidente(srk_tp_acdt),
    srk_lesao BIGINT REFERENCES gold.dim_lesao(srk_lesao),
    srk_agnt_csdr BIGINT REFERENCES gold.dim_agente_causador(srk_agnt_csdr),
    srk_cid10 BIGINT REFERENCES gold.dim_cid10(srk_cid10),
    
    idade_trabalhador INTEGER
);