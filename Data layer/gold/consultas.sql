-- 1. TOP 15 Causas de acidentes
SELECT 
    ag.descricao as agente_causador,
    COUNT(*) as total_acidentes,
    COUNT(DISTINCT f.srk_cne) as setores_afetados
FROM gold.fat_act_trb f
JOIN gold.dim_agt_cdr ag ON f.srk_agt_cdr = ag.srk_agt_cdr
WHERE ag.descricao <> 'Não identificado'
GROUP BY ag.descricao
ORDER BY total_acidentes DESC
LIMIT 15;

-- 2. OCUPAÇÕES CRÍTICAS
WITH acidentes_ocupacao AS (
    SELECT 
        cbo.descricao as ocupacao,
        l.natureza_lesao,
        COUNT(*) as casos
    FROM gold.fat_act_trb f
    JOIN gold.dim_cbo cbo ON f.srk_cbo = cbo.srk_cbo
    JOIN gold.dim_lso l ON f.srk_lso = l.srk_lso
    WHERE cbo.descricao <> 'Não identificado'
      AND l.natureza_lesao IS NOT NULL
    GROUP BY cbo.descricao, l.natureza_lesao
),
total_por_ocupacao AS (
    SELECT 
        ocupacao,
        SUM(casos) as total_acidentes,
        COUNT(DISTINCT natureza_lesao) as tipos_lesao_diferentes
    FROM acidentes_ocupacao
    GROUP BY ocupacao
)
SELECT 
    t.ocupacao,
    t.total_acidentes,
    t.tipos_lesao_diferentes,
    STRING_AGG(a.natureza_lesao || ' (' || a.casos || ')', ', ' ORDER BY a.casos DESC) as top_lesoes
FROM total_por_ocupacao t
JOIN acidentes_ocupacao a ON t.ocupacao = a.ocupacao
WHERE t.total_acidentes > 1000
GROUP BY t.ocupacao, t.total_acidentes, t.tipos_lesao_diferentes
ORDER BY t.total_acidentes DESC
LIMIT 10;


-- 3. DEMORA NA EMISSÃO DE CAT 
WITH tempo_emissao AS (
    SELECT 
        cne.descricao as setor,
        (t_ems.chv_tmp_org - t_act.chv_tmp_org) as dias_atraso
    FROM gold.fat_act_trb f
    JOIN gold.dim_cne cne ON f.srk_cne = cne.srk_cne
    JOIN gold.dim_tmp t_act ON f.srk_tmp_act = t_act.srk_tmp
    JOIN gold.dim_tmp t_ems ON f.srk_tmp_ems = t_ems.srk_tmp
    WHERE t_ems.chv_tmp_org >= t_act.chv_tmp_org
)
SELECT 
    setor,
    COUNT(*) as total_cats,
    ROUND(AVG(dias_atraso), 1) as media_dias,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dias_atraso) as mediana_dias,
    COUNT(*) FILTER (WHERE dias_atraso > 15) as casos_atraso_grave,
    ROUND(COUNT(*) FILTER (WHERE dias_atraso > 15) * 100.0 / COUNT(*), 1) as perc_atraso
FROM tempo_emissao
GROUP BY setor
HAVING COUNT(*) > 50
ORDER BY perc_atraso DESC, media_dias DESC;

-- 4. Padrão ao longo do ano
WITH acidentes_mes AS (
    SELECT 
        t.mes,
        t.nome_mes,
        COUNT(*) as total_acidentes
    FROM gold.fat_act_trb f
    JOIN gold.dim_tmp t ON f.srk_tmp_act = t.srk_tmp
    GROUP BY t.mes, t.nome_mes
)
SELECT 
    mes,
    nome_mes,
    total_acidentes,
    ROUND(total_acidentes * 100.0 / SUM(total_acidentes) OVER (), 1) as perc_anual,
    RANK() OVER (ORDER BY total_acidentes DESC) as ranking_mes
FROM acidentes_mes
ORDER BY mes;

-- 5. AGENTE CAUSADOR x PARTE DO CORPO 
WITH combinacoes AS (
    SELECT 
        ag.descricao as agente,
        l.parte_corpo_atingida,
        COUNT(*) as casos
    FROM gold.fat_act_trb f
    JOIN gold.dim_agt_cdr ag ON f.srk_agt_cdr = ag.srk_agt_cdr
    JOIN gold.dim_lso l ON f.srk_lso = l.srk_lso
    WHERE ag.descricao IS NOT NULL 
      AND l.parte_corpo_atingida IS NOT NULL
    GROUP BY ag.descricao, l.parte_corpo_atingida
),
total_agente AS (
    SELECT agente, SUM(casos) as total
    FROM combinacoes
    GROUP BY agente
)
SELECT 
    c.agente,
    c.parte_corpo_atingida,
    c.casos,
    t.total as total_agente,
    ROUND(c.casos * 100.0 / t.total, 1) as perc_do_agente
FROM combinacoes c
JOIN total_agente t ON c.agente = t.agente
WHERE t.total > 200
ORDER BY t.total DESC, c.casos DESC
LIMIT 30;


-- 6. DIAGNÓSTICOS (CID) - Doenças/lesões por profissão
WITH cid_ocupacao AS (
    SELECT 
        cid.descricao as diagnostico,
        cbo.descricao as ocupacao,
        COUNT(*) as casos
    FROM gold.fat_act_trb f
    JOIN gold.dim_cid cid ON f.srk_cid = cid.srk_cid
    JOIN gold.dim_cbo cbo ON f.srk_cbo = cbo.srk_cbo
    WHERE cid.descricao IS NOT NULL
    GROUP BY cid.descricao, cbo.descricao
),
total_cid AS (
    SELECT diagnostico, SUM(casos) as total
    FROM cid_ocupacao
    GROUP BY diagnostico
)
SELECT 
    c.diagnostico,
    t.total as total_casos,
    STRING_AGG(c.ocupacao || ' (' || c.casos || ')', ', ' ORDER BY c.casos DESC) as principais_ocupacoes
FROM cid_ocupacao c
JOIN total_cid t ON c.diagnostico = t.diagnostico
WHERE t.total > 100
GROUP BY c.diagnostico, t.total
ORDER BY t.total DESC
LIMIT 15;

-- 7. Ranking de estados com mais acidentes
SELECT 
    m.uf,
    COUNT(*) as total_acidentes,
    COUNT(DISTINCT f.srk_emp) as empresas_distintas,
    RANK() OVER (ORDER BY COUNT(*) DESC) as ranking_brasil
FROM gold.fat_act_trb f
JOIN gold.dim_mnc m ON f.srk_mnc_act = m.srk_mnc
WHERE m.uf <> 'Não identificado'
GROUP BY m.uf
ORDER BY total_acidentes DESC;

-- 8. EMPRESAS REINCIDENTES
WITH acidentes_empresa AS (
    SELECT 
        e.srk_emp,
        cne.descricao as setor,
        COUNT(*) as total_cats,
        COUNT(DISTINCT f.srk_trb) as trabalhadores_distintos,
        COUNT(DISTINCT DATE_TRUNC('month', t.chv_tmp_org)) as meses_com_acidentes
    FROM gold.fat_act_trb f
    JOIN gold.dim_emp e ON f.srk_emp = e.srk_emp
    JOIN gold.dim_cne cne ON e.srk_cne = cne.srk_cne
    JOIN gold.dim_tmp t ON f.srk_tmp_act = t.srk_tmp
    GROUP BY e.srk_emp, cne.descricao
)
SELECT 
    setor,
    total_cats,
    trabalhadores_distintos,
    meses_com_acidentes,
    ROUND(total_cats::NUMERIC / meses_com_acidentes, 1) as cats_por_mes,
    RANK() OVER (ORDER BY total_cats DESC) as ranking
FROM acidentes_empresa
WHERE total_cats > 10
ORDER BY total_cats DESC
LIMIT 100;

-- 9. DISTRIBUIÇÃO ETÁRIA
WITH faixas AS (
    SELECT 
        CASE 
            WHEN f.idade_trabalhador < 18 THEN 'Menor de 18'
            WHEN f.idade_trabalhador BETWEEN 18 AND 24 THEN '18-24'
            WHEN f.idade_trabalhador BETWEEN 25 AND 34 THEN '25-34'
            WHEN f.idade_trabalhador BETWEEN 35 AND 44 THEN '35-44'
            WHEN f.idade_trabalhador BETWEEN 45 AND 54 THEN '45-54'
            WHEN f.idade_trabalhador >= 55 THEN '55+'
        END as faixa_etaria,
        COUNT(*) as total_acidentes
    FROM gold.fat_act_trb f
    WHERE f.idade_trabalhador IS NOT NULL
    GROUP BY faixa_etaria
)
SELECT 
    faixa_etaria,
    total_acidentes,
    ROUND(total_acidentes * 100.0 / SUM(total_acidentes) OVER (), 1) as percentual,
    RANK() OVER (ORDER BY total_acidentes DESC) as ranking
FROM faixas
ORDER BY 
    CASE faixa_etaria
        WHEN 'Menor de 18' THEN 1
        WHEN '18-24' THEN 2
        WHEN '25-34' THEN 3
        WHEN '35-44' THEN 4
        WHEN '45-54' THEN 5
        WHEN '55+' THEN 6
    END;


-- 10. TIPOS DE ACIDENTE MAIS COMUNS
SELECT 
    tp.descricao as tipo_acidente,
    COUNT(*) as total_casos,
    ROUND(AVG(f.idade_trabalhador), 1) as idade_media,
    COUNT(DISTINCT f.srk_cbo) as ocupacoes_afetadas,
    COUNT(DISTINCT f.srk_cne) as setores_afetados,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentual
FROM gold.fat_act_trb f
JOIN gold.dim_tpo_act tp ON f.srk_tpo_act = tp.srk_tpo_act
WHERE tp.descricao IS NOT NULL
GROUP BY tp.descricao
ORDER BY total_casos DESC;