with recursive final
as (select codigo, nome, codigo_pai, cast(nome as text) AS hierarquia
from classificacao
where codigo_pai is null
union all
select c.codigo, fn.nome, c.codigo_pai, cast(fn.hierarquia || ' --> ' || c.nome as text) as hierarquia
from classificacao c
inner join final fn on c.codigo_pai = fn.codigo)
select hierarquia, codigo_pai
from final fn
order by hierarquia;
