/*PROJETO FINAL - BANCO DE DADOS PARA DATA SCIENCE 
25/03/2026 
Daniele Damaris dos Santos de Araujo
Prof. Gustavo Mota */

RESTORE DATABASE BDFazenda
FROM DISK = 'D:\BDFazenda.bak'

USE BDFazenda

-- Verificando tabelas do Banco que ainda é desconhecido
SELECT name
FROM sys.tables;

-- Consultando integridade de tabelas
SELECT TOP 1 *
FROM custo;

SELECT TOP 1 *
FROM filial;

SELECT TOP 1 *
FROM venda;

-- Alterando tipo de dados para criar minha Primarry Key
ALTER TABLE custo
ALTER COLUMN id_custo INT NOT NULL;

ALTER TABLE filial
ALTER COLUMN id_filial INT NOT NULL;

ALTER TABLE venda
ALTER COLUMN id_venda INT NOT NULL;

-- Criando as chaves primárias de cada tabela
ALTER TABLE custo
ADD CONSTRAINT PK_custo PRIMARY KEY(id_custo);

ALTER TABLE filial
ADD CONSTRAINT PK_filial  PRIMARY KEY(id_filial);

ALTER TABLE venda
ADD CONSTRAINT PK_venda PRIMARY KEY(id_venda);

-- Criando os relacionamentos entre tabelas - Chave Estrangeira
ALTER TABLE venda
ADD CONSTRAINT FK_venda_filial 
FOREIGN KEY (id_filial) REFERENCES filial (id_filial);

ALTER TABLE custo
ADD CONSTRAINT FK_custo_filial
FOREIGN KEY (id_filial) REFERENCES filial (id_filial);

/* ELABORANDO CONSULTAS
Elabore consultas SQL para trazer os seguintes resultados:
1. Exibir todas as vendas cujo valor seja superior a R$ 50.000,00.
2. Listar todos os custos, apresentando também o nome da filial responsável por cada registro.
3. Calcular o valor total de custos agrupado por filial, exibindo o nome da filial e o total correspondente.
4. Apresentar o valor total vendido para cada item, considerando a soma de todas as vendas.
5. Calcular o valor total vendido por item em cada filial, ordenando o resultado pelo nome da filial.*/

-- 1
SELECT *
FROM venda
WHERE valor_venda > 50000.00;

--2
SELECT c.id_custo,
	 c.data_custo,
	 c.descricao_custo,
	 c.valor_custo,
	 f.nome_filial
FROM custo AS c
INNER JOIN filial AS f
	ON c.id_filial = f.id_filial;

-- 3
SELECT f.nome_filial,
	   SUM(c.valor_custo) AS custo_total
FROM custo AS c
INNER JOIN filial AS f
	ON c.id_filial = f.id_filial
GROUP BY f.nome_filial;

--4
SELECT v.item,
	   SUM(v.valor_venda) AS total_venda
FROM venda AS v
GROUP BY v.item;

--5
SELECT v.item,
	   SUM(v.valor_venda) AS total_venda,
	   f.nome_filial
FROM venda AS v
INNER JOIN filial AS f
	ON v.id_filial = f.id_filial
GROUP BY f.nome_filial, v.item
ORDER BY f.nome_filial ASC;

-- CRIANDO VIEWS 
-- View VW_resumo_vendas
GO
CREATE VIEW VW_resumo_vendas AS
SELECT 
	v.id_venda,
	v.data_venda,
	v.item,
	v.valor_venda,
	f.nome_filial,
	f.estado
FROM venda as v
INNER JOIN filial AS f
	ON v.id_filial = f.id_filial;

-- View VW_resumo_custos
GO
CREATE VIEW VW_resumo_custos AS
SELECT	
	c.id_custo,
	c.data_custo,
	c.descricao_custo,
	c.valor_custo,
	f.nome_filial,
	f.estado
FROM custo AS c
INNER JOIN filial AS f
	ON c.id_filial = f.id_filial;

-- Criando a Procedure
GO
CREATE PROCEDURE SP_filtro_item
@item VARCHAR(30)
AS
SELECT *
FROM VW_resumo_vendas
WHERE item = @item;

--
BACKUP DATABASE BDFazenda
TO DISK = 'D:\bkp_bdfazenda.bak';