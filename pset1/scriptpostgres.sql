psql -U postgres
computacao@raiz

CREATE USER henrique WITH PASSWORD '19812019';
ALTER USER henrique WITH SUPERUSER;

CREATE DATABASE uvv
    WITH 
    OWNER = henrique
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    TEMPLATE = template0;

GRANT TEMPORARY, CONNECT ON DATABASE uvv TO PUBLIC;

GRANT ALL ON DATABASE uvv TO henrique;

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TABLES TO henrique;

exit
psql -U henrique uvv
19812019

CREATE SCHEMA elmasri
AUTHORIZATION henrique;

SHOW SEARCH_PATH;
SELECT CURRENT_SCHEMA();
SET SEARCH_PATH TO elmasri, "\$user", public;
ALTER USER henrique SET SEARCH_PATH TO elmasri, "\$user", public;

CREATE TABLE public.funcionario (
                cpf CHAR(11) NOT NULL,
                primeiro_nome VARCHAR(15) NOT NULL,
                nome_meio CHAR(1),
                ultimo_nome VARCHAR(15) NOT NULL,
                data_nascimento DATE,
                endereco VARCHAR(50),
                sexo CHAR(1),
                salario NUMERIC(10,2),
                cpf_supervisor CHAR(11),
                numero_departamento INTEGER NOT NULL,
                CONSTRAINT funcionario_pk PRIMARY KEY (cpf)
);
COMMENT ON TABLE public.funcionario IS 'References

funcionario through (cpf_gerente)
Referenced By

localizacoes_departamento referencing (numero_departamento)
projeto referencing (numero_departamento)';
COMMENT ON COLUMN public.funcionario.cpf IS 'CPF do funcionário. Será a PK da tabela.';
COMMENT ON COLUMN public.funcionario.primeiro_nome IS 'Primeiro nome do funcionário.';
COMMENT ON COLUMN public.funcionario.nome_meio IS 'Inicial do nome do meio.';
COMMENT ON COLUMN public.funcionario.ultimo_nome IS 'Sobrenome do funcionário.';
COMMENT ON COLUMN public.funcionario.endereco IS 'Endereço do funcionário.';
COMMENT ON COLUMN public.funcionario.sexo IS 'Sexo do funcionário.';
COMMENT ON COLUMN public.funcionario.salario IS 'Salário do funcionário.';
COMMENT ON COLUMN public.funcionario.cpf_supervisor IS 'CPF do supervisor. Será uma FK para a própria tabela (um auto-relacionamento).';
COMMENT ON COLUMN public.funcionario.numero_departamento IS 'Número do departamento do funcionário.';


CREATE TABLE public.dependente (
                cpf_funcionario CHAR(11) NOT NULL,
                nome_dependente VARCHAR(15) NOT NULL,
                sexo CHAR(1),
                data_nascimento DATE,
                parentesco VARCHAR(15),
                CONSTRAINT dependente_pk PRIMARY KEY (cpf_funcionario, nome_dependente)
);
COMMENT ON COLUMN public.dependente.cpf_funcionario IS 'CPF do funcionário. Faz parte da PK desta tabela e é uma FK para a tabela funcionário.';
COMMENT ON COLUMN public.dependente.nome_dependente IS 'Nome do dependente. Faz parte da PK desta tabela.';
COMMENT ON COLUMN public.dependente.sexo IS 'Sexo do dependente.';
COMMENT ON COLUMN public.dependente.data_nascimento IS 'Data de nascimento do dependente.';
COMMENT ON COLUMN public.dependente.parentesco IS 'Descrição do parentesco do dependente com o funcionário.';


CREATE TABLE public.departamento (
                numero_departamento INTEGER NOT NULL,
                nome_departamento VARCHAR(15) NOT NULL,
                cpf_gerente CHAR(11) NOT NULL,
                data_inicio_gerente DATE,
                CONSTRAINT departamento_pk PRIMARY KEY (numero_departamento)
);
COMMENT ON COLUMN public.departamento.numero_departamento IS 'Número do departamento. É a PK desta tabela.';
COMMENT ON COLUMN public.departamento.nome_departamento IS 'Nome do departamento. Deve ser único.';
COMMENT ON COLUMN public.departamento.cpf_gerente IS 'CPF do gerente do departamento. É uma FK para a tabela funcionários.';
COMMENT ON COLUMN public.departamento.data_inicio_gerente IS 'Data do início do gerente no departamento.';


CREATE UNIQUE INDEX departamento_idx
 ON public.departamento
 ( nome_departamento );

CREATE TABLE public.projeto (
                numero_projeto INTEGER NOT NULL,
                nome_projeto VARCHAR(15) NOT NULL,
                local_projeto VARCHAR(15),
                numero_departamento INTEGER NOT NULL,
                CONSTRAINT projeto_pk PRIMARY KEY (numero_projeto)
);
COMMENT ON COLUMN public.projeto.numero_projeto IS 'Número do projeto. É a PK desta tabela.';
COMMENT ON COLUMN public.projeto.nome_projeto IS 'Nome do projeto. Deve ser único.';
COMMENT ON COLUMN public.projeto.local_projeto IS 'Localização do projeto.';
COMMENT ON COLUMN public.projeto.numero_departamento IS 'Número do departamento. É uma FK para a tabela departamento.';


CREATE UNIQUE INDEX projeto_idx
 ON public.projeto
 ( nome_projeto );

CREATE TABLE public.trabalha_em (
                cpf_funcionario CHAR(11) NOT NULL,
                numero_projeto INTEGER NOT NULL,
                horas NUMERIC(3,1) NOT NULL,
                CONSTRAINT trabalha_em_pk PRIMARY KEY (cpf_funcionario, numero_projeto)
);
COMMENT ON COLUMN public.trabalha_em.cpf_funcionario IS 'CPF do funcionário. Faz parte da PK desta tabela e é uma FK para a tabela funcionário.';
COMMENT ON COLUMN public.trabalha_em.numero_projeto IS 'Número do projeto. Faz parte da PK desta tabela e é uma FK para a tabela projeto.';
COMMENT ON COLUMN public.trabalha_em.horas IS 'Horas trabalhadas pelo funcionário neste projeto.';


CREATE TABLE public.localizacoes_departamento (
                numero_departamento INTEGER NOT NULL,
                local VARCHAR(15) NOT NULL,
                CONSTRAINT localizacoes_departamento_pk PRIMARY KEY (numero_departamento, local)
);
COMMENT ON COLUMN public.localizacoes_departamento.numero_departamento IS 'Número do departamento. Faz parta da PK desta tabela e também é uma FK para a tabela departamento.';
COMMENT ON COLUMN public.localizacoes_departamento.local IS 'Localização do departamento. Faz parte da PK desta tabela.';


ALTER TABLE public.funcionario ADD CONSTRAINT funcionario_funcionario_fk
FOREIGN KEY (cpf_supervisor)
REFERENCES public.funcionario (cpf)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.dependente ADD CONSTRAINT funcionario_dependente_fk
FOREIGN KEY (cpf_funcionario)
REFERENCES public.funcionario (cpf)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.departamento ADD CONSTRAINT funcionario_departamento_fk
FOREIGN KEY (cpf_gerente)
REFERENCES public.funcionario (cpf)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.trabalha_em ADD CONSTRAINT funcionario_trabalha_em_fk
FOREIGN KEY (cpf_funcionario)
REFERENCES public.funcionario (cpf)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.localizacoes_departamento ADD CONSTRAINT departamento_localizacoes_departamento_fk
FOREIGN KEY (numero_departamento)
REFERENCES public.departamento (numero_departamento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.projeto ADD CONSTRAINT departamento_projeto_fk
FOREIGN KEY (numero_departamento)
REFERENCES public.departamento (numero_departamento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.trabalha_em ADD CONSTRAINT projeto_trabalha_em_fk
FOREIGN KEY (numero_projeto)
REFERENCES public.projeto (numero_projeto)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE departamento
ADD CONSTRAINT nome_departamento UNIQUE(nome_departamento);

ALTER TABLE projeto
ADD CONSTRAINT nome_projeto UNIQUE(nome_projeto);

ALTER TABLE funcionario
ADD CONSTRAINT check_types 
CHECK (sexo in ('M', 'F'));

alter table departamento
set schema elmasri;


alter table dependente
set schema elmasri;


alter table funcionario
set schema elmasri;


alter table localizacoes_departamento
set schema elmasri;


alter table projeto
set schema elmasri;


alter table trabalha_em
set schema elmasri;

insert into funcionario (primeiro_nome, nome_meio, ultimo_nome, cpf, data_nascimento, endereco, sexo, salario, numero_departamento)
values ('Jorge', 'E', 'Brito', '88866555576', '1937-11-10', 'Rua do Horto, 35, São Paulo, SP', 'M', '55000', '1');

insert into funcionario (primeiro_nome, nome_meio, ultimo_nome, cpf, data_nascimento, endereco, sexo, salario, cpf_supervisor, numero_departamento)
values ('Jennifer', 'S', 'Souza', '98765432168', '1941-06-20', 'Av. Arthur de Lima, 54, Santo André, SP', 'F', '43.000', '88866555576', '4'),
('Fernando', 'T', 'Wong', '33344555587', '1955-12-05', 'Rua das Lapa, 34, São Paulo, SP', 'M', '40000', '88866555576', '5'),
('Alice', 'J', 'Zelaya', '99988777767', '1968-01-19', 'Rua Souza Lima, 35, Curitiba, PR', 'F', '25000', '98765432168', '4'),
('André', 'V', 'Pereira', '98798798733', '1969-03-29', 'Rua Timbira, 35, São Paulo, SP', 'M', '25000', '98765432168', '4'),
('Ronaldo', 'K', 'Lima', '66688444476', '1962-09-15', 'Rua Rebouças, 65, Piracicaba, SP', 'M', '38000', '33344555587', '5'),
('Joice', 'A', 'Leite', '45345345376', '1972-07-31', 'Av. Lucas Obes, 74, São Paulo, SP', 'F', '25000', '33344555587', '4'),
('João', 'B', 'Silva', '12345678966', '1965-01-09', 'Rua das Flores, 751, São Paulo, SP', 'M', '30000', '33344555587', '5');

insert into departamento (nome_departamento, numero_departamento, cpf_gerente, data_inicio_gerente)
values ('Pesquisa', '5', '33344555587', '1988-05-22'),
('Administração', '4', '98765432168', '1995-01-01'),
('Matriz', '1', '88866555576', '1981-06-19');

insert into localizacoes_departamento (numero_departamento, local) 
values ('1', 'São Paulo'),
('4', 'Mauá'),
('5', 'Santo André'),
('5', 'Itu'),
('5', 'São Paulo');

insert into projeto (numero_projeto, nome_projeto, local_projeto, numero_departamento)
values ('1', 'ProdutoX', 'Santo André', '5'),
('2', 'ProdutoY', 'Itu', '5'),
('3', 'ProdutoZ', 'São Paulo', '5'),
('10', 'Informatização', 'Mauá', '4'),
('20', 'Reorganização', 'São Paulo', '1'),
('30', 'Novosbenefícios', 'Mauá', '4');

insert into dependente (cpf_funcionario, nome_dependente, sexo, data_nascimento, parentesco)
values ('33344555587', 'Alicia', 'F', '1986-04-05', 'Filha'),
('33344555587', 'Tiago', 'M', '1983-10-25', 'Filho'),
('33344555587', 'Janaína', 'F', '1958-05-03', 'Esposa'),
('98765432168', 'Antonio', 'M', '1942-02-28', 'Marido'),
(12345678966, 'Michael', 'M', '1988-01-04', 'Filho'),
(12345678966, 'Alicia', 'F', '1988-12-30', 'Filha'),
(12345678966, 'Elizabeth', 'F', '1967-05-05', 'Esposa');

insert into trabalha_em (cpf_funcionario, numero_projeto, horas)
values('12345678966', '1', '32.5'),
('12345678966', '2', '7.5'),
('66688444476', '3', '40.0'),
('45345345376', '1', '20.0'),
('45345345376', '2', '20.0'),
('33344555587', '2', '10.0'),
('33344555587', '3', '10.0'),
('33344555587', '10', '10.0'),
('33344555587', '20', '10.0'),
('99988777767', '30', '30.0'),
('99988777767', '10', '10.0'),
('98798798733', '10', '35.0'),
('98798798733', '30', '5.0'),
('98765432168', '30', '20.0'),
('98765432168', '20', '15.0'),
('88866555576', '20', '0');
