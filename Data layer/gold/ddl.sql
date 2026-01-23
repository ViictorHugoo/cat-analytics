CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_tmp CASCADE;
CREATE TABLE gold.dim_tmp (
    srk_tmp BIGSERIAL PRIMARY KEY,
    chv_tmp_org DATE NOT NULL UNIQUE,
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

DROP TABLE IF EXISTS gold.dim_mnc CASCADE;
CREATE TABLE gold.dim_mnc (
    srk_mnc BIGSERIAL PRIMARY KEY,
    chv_mnc_org TEXT NOT NULL UNIQUE,
    nome TEXT,
    uf TEXT
);

DROP TABLE IF EXISTS gold.dim_cne CASCADE;
CREATE TABLE gold.dim_cne (
    srk_cne BIGSERIAL PRIMARY KEY,
    chv_cne_org BIGINT NOT NULL UNIQUE,
    codigo BIGINT,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_tpo_act CASCADE;
CREATE TABLE gold.dim_tpo_act (
    srk_tpo_act BIGSERIAL PRIMARY KEY,
    chv_tpo_act_org TEXT NOT NULL UNIQUE,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_lso CASCADE;
CREATE TABLE gold.dim_lso (
    srk_lso BIGSERIAL PRIMARY KEY,
    chv_lso_org TEXT NOT NULL UNIQUE,
    natureza_lesao TEXT,
    parte_corpo_atingida TEXT
);

DROP TABLE IF EXISTS gold.dim_agt_cdr CASCADE;
CREATE TABLE gold.dim_agt_cdr (
    srk_agt_cdr BIGSERIAL PRIMARY KEY,
    chv_agt_cdr_org TEXT NOT NULL UNIQUE,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_cid CASCADE;
CREATE TABLE gold.dim_cid (
    srk_cid BIGSERIAL PRIMARY KEY,
    chv_cid_org TEXT NOT NULL UNIQUE,
    codigo TEXT,
    descricao TEXT
);

DROP TABLE IF EXISTS gold.dim_trb CASCADE;
CREATE TABLE gold.dim_trb (
    srk_trb BIGSERIAL PRIMARY KEY,
    chv_trb_org TEXT NOT NULL UNIQUE,
    sexo TEXT,
    srk_cbo TEXT,
    srk_tmp_nsc DATE
);

DROP TABLE IF EXISTS gold.dim_emp CASCADE;
CREATE TABLE gold.dim_emp (
    srk_emp BIGSERIAL PRIMARY KEY,
    chv_emp_org TEXT NOT NULL UNIQUE,
    srk_cne BIGINT,
    srk_mnc TEXT
);

DROP TABLE IF EXISTS gold.fat_act_trb CASCADE;
CREATE TABLE gold.fat_act_trb (
    srk_fat BIGSERIAL PRIMARY KEY,
    chv_cat_org TEXT NOT NULL,
    
    srk_tmp_act BIGINT REFERENCES gold.dim_tmp(srk_tmp),
    srk_tmp_ems BIGINT REFERENCES gold.dim_tmp(srk_tmp),
    srk_tmp_nsc BIGINT REFERENCES gold.dim_tmp(srk_tmp),
    
    srk_trb BIGINT REFERENCES gold.dim_trb(srk_trb),
    srk_cbo BIGINT REFERENCES gold.dim_cbo(srk_cbo),
    srk_emp BIGINT REFERENCES gold.dim_emp(srk_emp),
    srk_cne BIGINT REFERENCES gold.dim_cne(srk_cne),
    
    srk_mnc_act BIGINT REFERENCES gold.dim_mnc(srk_mnc),
    srk_mnc_emp BIGINT REFERENCES gold.dim_mnc(srk_mnc),
    
    srk_tpo_act BIGINT REFERENCES gold.dim_tpo_act(srk_tpo_act),
    srk_lso BIGINT REFERENCES gold.dim_lso(srk_lso),
    srk_agt_cdr BIGINT REFERENCES gold.dim_agt_cdr(srk_agt_cdr),
    srk_cid BIGINT REFERENCES gold.dim_cid(srk_cid),
    
    idade_trabalhador INTEGER
);