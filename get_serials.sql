select 
	distinct
	replicate('0', 6 - len(mast.cust_no)) + cast (mast.cust_no as varchar)+ '-'+replicate('0', 3 - len(mast.cust_sequence)) + cast (mast.cust_sequence as varchar) as AccountNum,
	dev.serial_no,
	hist.reading_period,
	hist.reading_year,
	hist.read_dt,
	con.install_date,
	lot.street_number,
	lot.street_name,
	lot.city
	into #serials
from ub_master mast
inner join
	lot 
	on mast.lot_no=lot.lot_no
	and lot.misc_16 like '%irr%'
inner join
	ub_meter_con con
	on con.lot_no=mast.lot_no
	and con.install_date is not null
inner join
	ub_device dev
	on con.ub_device_id=dev.ub_device_id
inner join
	ub_meter_hist hist
	on replicate('0', 6 - len(hist.cust_no)) + cast (hist.cust_no as varchar)+ '-'+replicate('0', 3 - len(hist.cust_sequence)) + cast (hist.cust_sequence as varchar)=replicate('0', 6 - len(mast.cust_no)) + cast (mast.cust_no as varchar)+ '-'+replicate('0', 3 - len(mast.cust_sequence)) + cast (mast.cust_sequence as varchar)
	--and hist.reading_year=2018
	--and hist.reading_period in (6)
group by
	replicate('0', 6 - len(mast.cust_no)) + cast (mast.cust_no as varchar)+ '-'+replicate('0', 3 - len(mast.cust_sequence)) + cast (mast.cust_sequence as varchar),
	dev.serial_no,
	hist.reading_period,
	hist.reading_year,
	hist.read_dt,
	con.install_date,
	lot.street_number,
	lot.street_name,
	lot.city
order by
	replicate('0', 6 - len(mast.cust_no)) + cast (mast.cust_no as varchar)+ '-'+replicate('0', 3 - len(mast.cust_sequence)) + cast (mast.cust_sequence as varchar) asc,
	hist.reading_year asc,
	hist.reading_period asc



select 
	distinct
t.accountNum, t.serial_no, t.street_number,t.street_name,t.city
from #serials t
inner join (
    select AccountNum, max(install_date) as MaxDate,
	max(reading_year) as MaxYear
    from #serials
    group by AccountNum
) tm on t.AccountNum= tm.AccountNum and  t.install_date= tm.MaxDate and t.reading_year=tm.MaxYear
order by
	t.AccountNum

drop table #serials