CREATE DATABASE EX07

GO

USE EX07

GO

CREATE TABLE cliente (
    rg          varchar(10)     not null,
    cpf         varchar(11)     not null,
    nome        varchar(50)     not null,
    logradouro  varchar(50)     not null,
    numero      int             not null,
    PRIMARY KEY (rg)
);

GO

CREATE TABLE pedido (
    nota_fiscal     int             not null,
    valor           decimal(7, 2)   not null,
    data            date            not null,
    rg_cliente      varchar(10)     not null,
    PRIMARY KEY (nota_fiscal),
    FOREIGN KEY (rg_cliente) REFERENCES cliente (rg)
);

GO

CREATE TABLE fornecedor (
    codigo       int             not null,
    nome         varchar(50)     not null,
    logradouro   varchar(50)     not null,
    numero       int             null,
    pais         varchar(3)      not null,
    area         int             not null,
    telefone     varchar(15)     null,
    cnpj         varchar(14)     null,
    cidade       varchar(50)     null,
    transporte   varchar(20)     null,
    moeda        varchar(3)      not null,
    PRIMARY KEY (codigo)
);

GO

CREATE TABLE mercadoria (
    codigo           int             not null,
    descricao        varchar(50)     not null,
    preco            decimal(7, 2)   not null,
    qtd              int             not null,
    cod_fornecedor   int             not null,
    PRIMARY KEY (codigo),
    FOREIGN KEY (cod_fornecedor) REFERENCES fornecedor (codigo)
);

GO

INSERT INTO cliente (rg, cpf, nome, logradouro, numero)
VALUES 
  ('29531844', '34519878040', 'Luiz André', 'R. Astorga', 500),
  ('13514996x', '84984285630', 'Maria Luiza', 'R. Piauí', 174),
  ('121985541', '23354997310', 'Ana Barbara', 'Av. Jaceguai', 1141),
  ('23987746x', '43587669920', 'Marcos Alberto', 'R. Quinze', 22);

GO

INSERT INTO pedido (nota_fiscal, valor, data, rg_cliente)
VALUES 
  (1001, 754.00, '2018-04-01', '121985541'),
  (1002, 350.00, '2018-04-02', '121985541'),
  (1003, 30.00, '2018-04-02', '29531844'),
  (1004, 1500.00, '2018-04-03', '13514996x');

GO

INSERT INTO fornecedor (codigo, nome, logradouro, numero, pais, area, telefone, cnpj, cidade, transporte, moeda)
VALUES 
  (1, 'Clone', 'Av. Nações Unidas, 12000', 12000, 'BR', 55, '1141487000', NULL, 'São Paulo', NULL, 'R$'),
  (2, 'Logitech', '28th Street, 100', 100, '3', 1, '2127695100', NULL, NULL, 'Avião', 'US$'),
  (3, 'LG', 'Rod. Castello Branco', NULL, 'BR', 55, '800664400', '4159978100001', 'Sorocaba', NULL, 'R$'),
  (4, 'PcChips', 'Ponte da Amizade', NULL, 'PY', 595, NULL, NULL, NULL, 'Navio', 'US$');

GO

INSERT INTO mercadoria (codigo, descricao, preco, qtd, cod_fornecedor)
VALUES 
  (10, 'Mouse', 24.00, 30, 1),
  (11, 'Teclado', 50.00, 20, 1),
  (12, 'Cx. De Som', 30.00, 8, 2),
  (13, 'Monitor 17', 350.00, 4, 3),
  (14, 'Notebook', 1500.00, 7, 4);

GO

SELECT CAST(valor - valor * 0.10 AS DECIMAL(7,2)) as Desconto10Porcento 
FROM pedido
WHERE nota_fiscal = 1003

GO

SELECT CAST(valor - valor * 0.05 AS decimal(7,2)) AS Desconto05Porcento 
FROM pedido
WHERE valor > 700

GO

SELECT CAST(preco + preco * 0.20 AS DECIMAL(7,2)) AS Acrescimo20Porcento
FROM mercadoria
WHERE qtd < 10

GO

UPDATE mercadoria
SET preco = preco + preco * 0.20
WHERE qtd < 10

GO

SELECT p.data, p.valor 
FROM cliente c, pedido p
WHERE c.rg = p.rg_cliente
	  AND c.nome = 'luiz andré'

GO

SELECT SUBSTRING(c.cpf, 1, 3) + '.' + SUBSTRING(c.cpf, 4, 3) + '.' + SUBSTRING(c.cpf, 7, 3) + '-' + SUBSTRING(c.cpf, 10, 2), c.nome as CPF,
	   C.logradouro + ', ' +  CAST(C.numero AS VARCHAR(7)) AS Endereço
FROM cliente c, pedido p
WHERE c.rg = p.rg_cliente
	  AND p.nota_fiscal = 1004

GO

SELECT f.pais, f.transporte
FROM mercadoria m, fornecedor f
WHERE f.codigo = m.cod_fornecedor
	  AND m.descricao = 'Cx. De Som'

GO

SELECT m.descricao, m.qtd
FROM fornecedor f, mercadoria m
WHERE m.cod_fornecedor = f.codigo
	  AND f.nome = 'clone'

GO

SELECT Case when (f.numero is null) then
			f.logradouro + ' - ' + f.pais
	   ELSE
			f.logradouro + ', ' + CAST(f.numero AS nvarchar(10)) + ' - ' + f.pais
	   END AS Endereco,
	   Case when (SUBSTRING(f.telefone,1, 3) = '800') THEN
			'(' + SUBSTRING(f.telefone,1,3) + ') ' + SUBSTRING(f.telefone,4,3) + '-' +  SUBSTRING(f.telefone,7,4)
	   ELSE
			'(' + SUBSTRING(f.telefone,1,2) + ') ' + SUBSTRING(f.telefone,3,4) + '-' +  SUBSTRING(f.telefone,7,4)
	   END AS telefone
FROM fornecedor f, mercadoria m
WHERE f.codigo = m.cod_fornecedor
	  AND m.descricao = 'monitor 17'

GO

SELECT F.moeda
FROM fornecedor f, mercadoria m
WHERE f.codigo = m.cod_fornecedor
	  AND m.descricao like '%Notebook%'

GO

SELECT DATEDIFF(DAY, data, '03-02-2019') AS TempoPedidoDias,
	   case when(DATEDIFF(MONTH, data, '03-02-2019') > 6) then
				'Pedido Antigo'
	   else
				'Pedido Recente'
	   end as statusPedido
FROM pedido

GO

SELECT c.nome, COUNT(P.nota_fiscal) as qtdPedido
FROM cliente c, pedido p
WHERE c.rg = p.rg_cliente
Group by c.nome

GO
 
SELECT SUBSTRING(c.rg, 1, 8) + '-' +  SUBSTRING(c.rg, 9, 1) as RG,
	   SUBSTRING(c.cpf, 1, 3) + '.' + SUBSTRING(c.cpf, 4, 3) + '.' + SUBSTRING(c.cpf, 7, 3) + '-' + SUBSTRING(c.cpf, 10, 2), c.nome as CPF,
	   C.logradouro + ', ' +  CAST(C.numero AS VARCHAR(7)) AS Endereço
FROM cliente c LEFT OUTER JOIN pedido p on c.rg = p.rg_cliente
where p.nota_fiscal is null
