--1
select avg(f.salario) as media_salarial, d.nome_departamento
from funcionario f
inner join departamento d
on d.numero_departamento = f.numero_departamento
group by d.nome_departamento;

--2
select avg(f.salario) as media_salarial, f.sexo
from funcionario f
group by f.sexo;

--3
select  d.nome_departamento,
concat(primeiro_nome, " ", nome_meio, ". ", ultimo_nome) as nome_completo,
f.data_nascimento,
timestampdiff(year, data_nascimento, curdate()) as idade,
f.salario
from departamento d
inner join funcionario f
on f.numero_departamento = d.numero_departamento;

--4
select concat(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) as nome_funcionario,
f.data_nascimento,
timestampdiff(year, data_nascimento, curdate()) as idade,
f.salario as salario_atual,
(case
when (f.salario < 35000) then f.salario + (f.salario * 0.2)
else f.salario + (f.salario * 0.15)
end) as salario_ajustado
from funcionario f;
