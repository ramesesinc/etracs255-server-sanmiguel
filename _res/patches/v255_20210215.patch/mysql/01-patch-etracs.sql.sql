/* 254032-03017 */

drop table if exists rptbill_ledger_account
;
drop table if exists rptbill_ledger_item
;


/* 254032-03018 */

alter table faasbacktax modify column tdno varchar(25) null
;
drop table if exists cashreceiptpayment_eor
;


/* 254032-03019 */

/*==================================================
*
*  CDU RATING SUPPORT 
*
=====================================================*/

alter table bldgrpu add cdurating varchar(15);

alter table bldgtype add usecdu int;
update bldgtype set usecdu = 0 where usecdu is null;

alter table bldgtype_depreciation 
  add excellent decimal(16,2),
  add verygood decimal(16,2),
  add good decimal(16,2),
  add average decimal(16,2),
  add fair decimal(16,2),
  add poor decimal(16,2),
  add verypoor decimal(16,2),
  add unsound decimal(16,2);



alter table batchgr_error drop column barangayid;
alter table batchgr_error drop column barangay;
alter table batchgr_error drop column tdno;

drop table if exists vw_batchgr_error;
drop view if exists vw_batchgr_error;

create view vw_batchgr_error 
as 
select 
    err.*,
    f.tdno,
    f.prevtdno, 
    f.fullpin as fullpin, 
    rp.pin as pin,
    b.name as barangay,
    o.name as lguname
from batchgr_error err 
inner join faas f on err.objid = f.objid 
inner join realproperty rp on f.realpropertyid = rp.objid 
inner join barangay b on rp.barangayid = b.objid 
inner join sys_org o on f.lguid = o.objid;




/*=============================================================
*
* SKETCH 
*
==============================================================*/
CREATE TABLE `faas_sketch` (
  `objid` varchar(50) NOT NULL DEFAULT '',
  `drawing` text NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



create index FK_faas_sketch_faas  on faas_sketch(objid);

alter table faas_sketch 
  add constraint FK_faas_sketch_faas foreign key(objid) 
  references faas(objid);


  
/*=============================================================
*
* CUSTOM RPU SUFFIX SUPPORT
*
==============================================================*/  

CREATE TABLE `rpu_type_suffix` (
  `objid` varchar(50) NOT NULL,
  `rputype` varchar(20) NOT NULL,
  `from` int(11) NOT NULL,
  `to` int(11) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
; 



insert into rpu_type_suffix (
  objid, rputype, `from`, `to`
)
values('LAND', 'land', 0, 0),
('BLDG-1001-1999', 'bldg', 1001, 1999),
('MACH-2001-2999', 'mach', 2001, 2999),
('PLANTTREE-3001-6999', 'planttree', 3001, 6999),
('MISC-7001-7999', 'misc', 7001, 7999)
;



/*=============================================================
*
* MEMORANDA TEMPLATE UPDATE 
*
==============================================================*/  
alter table memoranda_template add fields text;

update memoranda_template set fields = '[]' where fields is null;
  

/* 254032-03019.01 */

/*==================================================
*
*  BATCH GR UPDATES
*
=====================================================*/
drop table if exists batchgr_error;
drop table if exists batchgr_items_forrevision;
drop table if exists batchgr_log;
drop view if exists vw_batchgr_error;

CREATE TABLE `batchgr` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `ry` int(255) NOT NULL,
  `lgu_objid` varchar(50) NOT NULL,
  `barangay_objid` varchar(50) NOT NULL,
  `rputype` varchar(15) DEFAULT NULL,
  `classification_objid` varchar(50) DEFAULT NULL,
  `section` varchar(10) DEFAULT NULL,
  `count` int(255) NOT NULL,
  `completed` int(255) NOT NULL,
  `error` int(255) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


create index `ix_barangay_objid` on batchgr(`barangay_objid`);
create index `ix_state` on batchgr(`state`);
create index `fk_lgu_objid` on batchgr(`lgu_objid`);

alter table batchgr add constraint `fk_batchgr_barangay_objid` 
  foreign key (`barangay_objid`) references `barangay` (`objid`);
  
alter table batchgr add constraint `fk_lgu_objid` 
  foreign key (`lgu_objid`) references `sys_org` (`objid`);



CREATE TABLE `batchgr_item` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `rputype` varchar(15) NOT NULL,
  `tdno` varchar(50) NOT NULL,
  `fullpin` varchar(50) NOT NULL,
  `pin` varchar(50) NOT NULL,
  `suffix` int(255) NOT NULL,
  `newfaasid` varchar(50) DEFAULT NULL,
  `error` text,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index `fk_batchgr_item_batchgr` on batchgr_item (`parent_objid`);
create index `fk_batchgr_item_newfaasid` on batchgr_item (`newfaasid`);
create index `fk_batchgr_item_tdno` on batchgr_item (`tdno`);
create index `fk_batchgr_item_pin` on batchgr_item (`pin`);


alter table batchgr_item add constraint `fk_batchgr_item_objid` 
	foreign key (`objid`) references `faas` (`objid`);

alter table batchgr_item add constraint `fk_batchgr_item_batchgr` 
	foreign key (`parent_objid`) references `batchgr` (`objid`);

alter table batchgr_item add constraint `fk_batchgr_item_newfaasid` 
	foreign key (`newfaasid`) references `faas` (`objid`);


CREATE TABLE `batchgr_forprocess` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


create index `fk_batchgr_forprocess_parentid` on batchgr_forprocess(`parent_objid`);

alter table batchgr_forprocess add constraint `fk_batchgr_forprocess_parentid` 
	foreign key (`parent_objid`) references `batchgr` (`objid`);

alter table batchgr_forprocess add constraint `fk_batchgr_forprocess_objid` 
	foreign key (`objid`) references `batchgr_item` (`objid`);

	


/* 254032-03019.02 */

/*==============================================
* EXAMINATION UPDATES
==============================================*/

alter table examiner_finding 
	add inspectedby_objid varchar(50),
	add inspectedby_name varchar(100),
	add inspectedby_title varchar(50),
	add doctype varchar(50)
;

create index ix_examiner_finding_inspectedby_objid on examiner_finding(inspectedby_objid)
;


update examiner_finding e, faas f set 
	e.inspectedby_objid = (select assignee_objid from faas_task where refid = f.objid and state = 'examiner' order by enddate desc limit 1),
	e.inspectedby_name = e.notedby,
	e.inspectedby_title = e.notedbytitle,
	e.doctype = 'faas'
where e.parent_objid = f.objid
;

update examiner_finding e, subdivision s set 
	e.inspectedby_objid = (select assignee_objid from subdivision_task where refid = s.objid and state = 'examiner' order by enddate desc limit 1),
	e.inspectedby_name = e.notedby,
	e.inspectedby_title = e.notedbytitle,
	e.doctype = 'subdivision'
where e.parent_objid = s.objid
;

update examiner_finding e, consolidation c set 
	e.inspectedby_objid = (select assignee_objid from consolidation_task where refid = c.objid and state = 'examiner' order by enddate desc limit 1),
	e.inspectedby_name = e.notedby,
	e.inspectedby_title = e.notedbytitle,
	e.doctype = 'consolidation'
where e.parent_objid = c.objid
;

update examiner_finding e, cancelledfaas c set 
	e.inspectedby_objid = (select assignee_objid from cancelledfaas_task where refid = c.objid and state = 'examiner' order by enddate desc limit 1),
	e.inspectedby_name = e.notedby,
	e.inspectedby_title = e.notedbytitle,
	e.doctype = 'cancelledfaas'
where e.parent_objid = c.objid
;



/*======================================================
*
*  ASSESSMENT NOTICE 
*
======================================================*/
alter table assessmentnotice modify column dtdelivered date null
;
alter table assessmentnotice add deliverytype_objid varchar(50)
;
update assessmentnotice set state = 'DELIVERED' where state = 'RECEIVED'
;


drop view if exists vw_assessment_notice
;

create view vw_assessment_notice
as 
select 
	a.objid,
	a.state,
	a.txnno,
	a.txndate,
	a.taxpayerid,
	a.taxpayername,
	a.taxpayeraddress,
	a.dtdelivered,
	a.receivedby,
	a.remarks,
	a.assessmentyear,
	a.administrator_name,
	a.administrator_address,
	fl.tdno,
	fl.displaypin as fullpin,
	fl.cadastrallotno,
	fl.titleno
from assessmentnotice a 
inner join assessmentnoticeitem i on a.objid = i.assessmentnoticeid
inner join faas_list fl on i.faasid = fl.objid
;


drop view if exists vw_assessment_notice_item 
;

create view vw_assessment_notice_item 
as 
select 
	ni.objid,
	ni.assessmentnoticeid, 
	f.objid AS faasid,
	f.effectivityyear,
	f.effectivityqtr,
	f.tdno,
	f.taxpayer_objid,
	e.name as taxpayer_name,
	e.address_text as taxpayer_address,
	f.owner_name,
	f.owner_address,
	f.administrator_name,
	f.administrator_address,
	f.rpuid, 
	f.lguid,
	f.txntype_objid, 
	ft.displaycode as txntype_code,
	rpu.rputype,
	rpu.ry,
	rpu.fullpin ,
	rpu.taxable,
	rpu.totalareaha,
	rpu.totalareasqm,
	rpu.totalbmv,
	rpu.totalmv,
	rpu.totalav,
	rp.section,
	rp.parcel,
	rp.surveyno,
	rp.cadastrallotno,
	rp.blockno,
	rp.claimno,
	rp.street,
	o.name as lguname, 
	b.name AS barangay,
	pc.code AS classcode,
	pc.name as classification 
FROM assessmentnoticeitem ni 
	INNER JOIN faas f ON ni.faasid = f.objid 
	LEFT JOIN txnsignatory ts on ts.refid = f.objid and ts.type='APPROVER'
	INNER JOIN rpu rpu ON f.rpuid = rpu.objid
	INNER JOIN propertyclassification pc ON rpu.classification_objid = pc.objid
	INNER JOIN realproperty rp ON f.realpropertyid = rp.objid
	INNER JOIN barangay b ON rp.barangayid = b.objid 
	INNER JOIN sys_org o ON f.lguid = o.objid 
	INNER JOIN entity e on f.taxpayer_objid = e.objid 
	INNER JOIN faas_txntype ft on f.txntype_objid = ft.objid 
;



/*======================================================
*
*  TAX CLEARANCE UPDATE
*
======================================================*/

alter table rpttaxclearance add reporttype varchar(15)
;

update rpttaxclearance set reporttype = 'fullypaid' where reporttype is null
;



/*============================================================
*
* 254032-03020
*
=============================================================*/
update cashreceiptitem_rpt_account set discount= 0 where discount is null;

alter table rptledger add lguid varchar(50);

update rptledger rl, barangay b, sys_org m set 
  rl.lguid = m.objid 
where rl.barangayid = b.objid 
and b.parentid = m.objid 
and m.orgclass = 'municipality';


update rptledger rl, barangay b, sys_org d, sys_org c set 
  rl.lguid = c.objid
where rl.barangayid = b.objid 
and b.parentid = d.objid 
and d.parent_objid = c.objid 
and d.orgclass = 'district';



create table `rptpayment` (
  `objid` varchar(100) not null,
  `type` varchar(50) default null,
  `refid` varchar(50) not null,
  `reftype` varchar(50) not null,
  `receiptid` varchar(50) default null,
  `receiptno` varchar(50) not null,
  `receiptdate` date not null,
  `paidby_name` longtext not null,
  `paidby_address` varchar(150) not null,
  `postedby` varchar(100) not null,
  `postedbytitle` varchar(50) not null,
  `dtposted` datetime not null,
  `fromyear` int(11) not null,
  `fromqtr` int(11) not null,
  `toyear` int(11) not null,
  `toqtr` int(11) not null,
  `amount` decimal(12,2) not null,
  `collectingagency` varchar(50) default null,
  `voided` int(11) not null,
  primary key(objid)
) engine=innodb default charset=utf8;

create index `fk_rptpayment_cashreceipt` on rptpayment(`receiptid`);
create index `ix_refid` on rptpayment(`refid`);
create index `ix_receiptno` on rptpayment(`receiptno`);

alter table rptpayment 
  add constraint `fk_rptpayment_cashreceipt` 
  foreign key (`receiptid`) references `cashreceipt` (`objid`);



create table `rptpayment_item` (
  `objid` varchar(50) not null,
  `parentid` varchar(100) not null,
  `rptledgerfaasid` varchar(50) default null,
  `year` int(11) not null,
  `qtr` int(11) default null,
  `revtype` varchar(50) not null,
  `revperiod` varchar(25) default null,
  `amount` decimal(16,2) not null,
  `interest` decimal(16,2) not null,
  `discount` decimal(16,2) not null,
  `partialled` int(11) not null,
  `priority` int(11) not null,
  primary key (`objid`)
) engine=innodb default charset=utf8;

create index `fk_rptpayment_item_parentid` on rptpayment_item (`parentid`);
create index `fk_rptpayment_item_rptledgerfaasid` on rptpayment_item (`rptledgerfaasid`);

alter table rptpayment_item
  add constraint `rptpayment_item_rptledgerfaas` foreign key (`rptledgerfaasid`) 
  references `rptledgerfaas` (`objid`);

alter table rptpayment_item
  add constraint `rptpayment_item_rptpayment` foreign key (`parentid`) 
  references `rptpayment` (`objid`);




create table `rptpayment_share` (
  `objid` varchar(50) not null,
  `parentid` varchar(100) default null,
  `revperiod` varchar(25) not null,
  `revtype` varchar(25) not null,
  `sharetype` varchar(25) not null,
  `item_objid` varchar(50) not null,
  `amount` decimal(16,4) not null,
  `discount` decimal(16,4) default null,
  primary key (`objid`)
) engine=innodb default charset=utf8;

create index `fk_rptpayment_share_parentid` on rptpayment_share(`parentid`);
create index `fk_rptpayment_share_item_objid` on  rptpayment_share(`item_objid`);

alter table rptpayment_share add constraint `rptpayment_share_itemaccount` 
  foreign key (`item_objid`) references `itemaccount` (`objid`);

alter table rptpayment_share add constraint `rptpayment_share_rptpayment` 
  foreign key (`parentid`) references `rptpayment` (`objid`);



insert into rptpayment(
  objid,
  type,
  refid,
  reftype,
  receiptid,
  receiptno,
  receiptdate,
  paidby_name,
  paidby_address,
  postedby,
  postedbytitle,
  dtposted,
  fromyear,
  fromqtr,
  toyear,
  toqtr,
  amount,
  collectingagency,
  voided
)
select
  objid,
  type, 
  rptledgerid as refid,
  'rptledger' as reftype,
  receiptid,
  receiptno,
  receiptdate,
  paidby_name,
  paidby_address,
  postedby,
  postedbytitle,
  dtposted,
  fromyear,
  fromqtr,
  toyear,
  toqtr,
  amount,
  collectingagency,
  voided
from rptledger_payment;


insert into rptpayment_item(
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revtype,
  revperiod,
  amount,
  interest,
  discount,
  partialled,
  priority
)
select
  concat(objid, '-basic') as objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  'basic' as revtype,
  revperiod,
  basic as amount,
  basicint as interest,
  basicdisc as discount,
  partialled,
  10000 as priority
from rptledger_payment_item;





insert into rptpayment_item(
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revtype,
  revperiod,
  amount,
  interest,
  discount,
  partialled,
  priority
)
select
  concat(objid, '-sef') as objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  'sef' as revtype,
  revperiod,
  sef as amount,
  sefint as interest,
  sefdisc as discount,
  partialled,
  10000 as priority
from rptledger_payment_item;


insert into rptpayment_item(
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revtype,
  revperiod,
  amount,
  interest,
  discount,
  partialled,
  priority
)
select
  concat(objid, '-sh') as objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  'sh' as revtype,
  revperiod,
  sh as amount,
  shint as interest,
  shdisc as discount,
  partialled,
  100 as priority
from rptledger_payment_item
where sh > 0;




insert into rptpayment_item(
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revtype,
  revperiod,
  amount,
  interest,
  discount,
  partialled,
  priority
)
select
  concat(objid, '-firecode') as objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  'firecode' as revtype,
  revperiod,
  firecode as amount,
  0 as interest,
  0 as discount,
  partialled,
  50 as priority
from rptledger_payment_item
where firecode > 0
;



insert into rptpayment_item(
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revtype,
  revperiod,
  amount,
  interest,
  discount,
  partialled,
  priority
)
select
  concat(objid, '-basicidle') as objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  'basicidle' as revtype,
  revperiod,
  basicidle as amount,
  basicidleint as interest,
  basicidledisc as discount,
  partialled,
  200 as priority
from rptledger_payment_item
where basicidle > 0
;



update cashreceipt_rpt set txntype = 'online' where txntype = 'rptonline'
;
update cashreceipt_rpt set txntype = 'manual' where txntype = 'rptmanual'
;
update cashreceipt_rpt set txntype = 'compromise' where txntype = 'rptcompromise'
;

update rptpayment set type = 'online' where type = 'rptonline'
;
update rptpayment set type = 'manual' where type = 'rptmanual'
;
update rptpayment set type = 'compromise' where type = 'rptcompromise'
;






  
create table landtax_report_rptdelinquency (
  objid varchar(50) not null,
  rptledgerid varchar(50) not null,
  barangayid varchar(50) not null,
  year int not null,
  qtr int null,
  revtype varchar(50) not null,
  amount decimal(16,2) not null,
  interest decimal(16,2) not null,
  discount decimal(16,2) not null,
  dtgenerated datetime not null, 
  generatedby_name varchar(255) not null,
  generatedby_title varchar(100) not null,
  primary key (objid)
)engine=innodb default charset=utf8
;




create view vw_rptpayment_item_detail as
select
  objid,
  parentid,
  rptledgerfaasid,
  year,
  qtr,
  revperiod, 
  case when rpi.revtype = 'basic' then rpi.amount else 0 end as basic,
  case when rpi.revtype = 'basic' then rpi.interest else 0 end as basicint,
  case when rpi.revtype = 'basic' then rpi.discount else 0 end as basicdisc,
  case when rpi.revtype = 'basic' then rpi.interest - rpi.discount else 0 end as basicdp,
  case when rpi.revtype = 'basic' then rpi.amount + rpi.interest - rpi.discount else 0 end as basicnet,
  case when rpi.revtype = 'basicidle' then rpi.amount + rpi.interest - rpi.discount else 0 end as basicidle,
  case when rpi.revtype = 'basicidle' then rpi.interest else 0 end as basicidleint,
  case when rpi.revtype = 'basicidle' then rpi.discount else 0 end as basicidledisc,
  case when rpi.revtype = 'basicidle' then rpi.interest - rpi.discount else 0 end as basicidledp,
  case when rpi.revtype = 'sef' then rpi.amount else 0 end as sef,
  case when rpi.revtype = 'sef' then rpi.interest else 0 end as sefint,
  case when rpi.revtype = 'sef' then rpi.discount else 0 end as sefdisc,
  case when rpi.revtype = 'sef' then rpi.interest - rpi.discount else 0 end as sefdp,
  case when rpi.revtype = 'sef' then rpi.amount + rpi.interest - rpi.discount else 0 end as sefnet,
  case when rpi.revtype = 'firecode' then rpi.amount + rpi.interest - rpi.discount else 0 end as firecode,
  case when rpi.revtype = 'sh' then rpi.amount + rpi.interest - rpi.discount else 0 end as sh,
  case when rpi.revtype = 'sh' then rpi.interest else 0 end as shint,
  case when rpi.revtype = 'sh' then rpi.discount else 0 end as shdisc,
  case when rpi.revtype = 'sh' then rpi.interest - rpi.discount else 0 end as shdp,
  rpi.amount + rpi.interest - rpi.discount as amount,
  rpi.partialled as partialled 
from rptpayment_item rpi
;


create view vw_landtax_report_rptdelinquency_detail 
as
select
  objid,
  rptledgerid,
  barangayid,
  year,
  qtr,
  dtgenerated,
  generatedby_name,
  generatedby_title,
  case when revtype = 'basic' then amount else 0 end as basic,
  case when revtype = 'basic' then interest else 0 end as basicint,
  case when revtype = 'basic' then discount else 0 end as basicdisc,
  case when revtype = 'basic' then interest - discount else 0 end as basicdp,
  case when revtype = 'basic' then amount + interest - discount else 0 end as basicnet,
  case when revtype = 'basicidle' then amount else 0 end as basicidle,
  case when revtype = 'basicidle' then interest else 0 end as basicidleint,
  case when revtype = 'basicidle' then discount else 0 end as basicidledisc,
  case when revtype = 'basicidle' then interest - discount else 0 end as basicidledp,
  case when revtype = 'basicidle' then amount + interest - discount else 0 end as basicidlenet,
  case when revtype = 'sef' then amount else 0 end as sef,
  case when revtype = 'sef' then interest else 0 end as sefint,
  case when revtype = 'sef' then discount else 0 end as sefdisc,
  case when revtype = 'sef' then interest - discount else 0 end as sefdp,
  case when revtype = 'sef' then amount + interest - discount else 0 end as sefnet,
  case when revtype = 'firecode' then amount else 0 end as firecode,
  case when revtype = 'firecode' then interest else 0 end as firecodeint,
  case when revtype = 'firecode' then discount else 0 end as firecodedisc,
  case when revtype = 'firecode' then interest - discount else 0 end as firecodedp,
  case when revtype = 'firecode' then amount + interest - discount else 0 end as firecodenet,
  case when revtype = 'sh' then amount else 0 end as sh,
  case when revtype = 'sh' then interest else 0 end as shint,
  case when revtype = 'sh' then discount else 0 end as shdisc,
  case when revtype = 'sh' then interest - discount else 0 end as shdp,
  case when revtype = 'sh' then amount + interest - discount else 0 end as shnet,
  amount + interest - discount as total
from landtax_report_rptdelinquency
;




create table `rptledger_item` (
  `objid` varchar(50) not null,
  `parentid` varchar(50) not null,
  `rptledgerfaasid` varchar(50) default null,
  `remarks` varchar(100) default null,
  `basicav` decimal(16,2) not null,
  `sefav` decimal(16,2) not null,
  `av` decimal(16,2) not null,
  `revtype` varchar(50) not null,
  `year` int(11) not null,
  `amount` decimal(16,2) not null,
  `amtpaid` decimal(16,2) not null,
  `priority` int(11) not null,
  `taxdifference` int(11) not null,
  `system` int(11) not null,
  primary key (`objid`)
) engine=innodb default charset=utf8
;

create index `fk_rptledger_item_rptledger` on rptledger_item (`parentid`)
; 

alter table rptledger_item 
  add constraint `fk_rptledger_item_rptledger` foreign key (`parentid`) 
  references `rptledger` (`objid`)
;



insert into rptledger_item (
  objid,
  parentid,
  rptledgerfaasid,
  remarks,
  basicav,
  sefav,
  av,
  revtype,
  year,
  amount,
  amtpaid,
  priority,
  taxdifference,
  system
)
select 
  concat(rli.objid, '-basic') as objid,
  rli.rptledgerid as parentid,
  rli.rptledgerfaasid,
  rli.remarks,
  ifnull(rli.basicav, rli.av),
  ifnull(rli.sefav, rli.av),
  rli.av,
  'basic' as revtype,
  rli.year,
  rli.basic as amount,
  rli.basicpaid as amtpaid,
  10000 as priority,
  rli.taxdifference,
  0 as system
from rptledgeritem rli 
  inner join rptledger rl on rli.rptledgerid = rl.objid 
where rl.state = 'APPROVED' 
and rli.basic > 0 
and rli.basicpaid < rli.basic
;




insert into rptledger_item (
  objid,
  parentid,
  rptledgerfaasid,
  remarks,
  basicav,
  sefav,
  av,
  revtype,
  year,
  amount,
  amtpaid,
  priority,
  taxdifference,
  system
)
select 
  concat(rli.objid, '-sef') as objid,
  rli.rptledgerid as parentid,
  rli.rptledgerfaasid,
  rli.remarks,
  ifnull(rli.basicav, rli.av),
  ifnull(rli.sefav, rli.av),
  rli.av,
  'sef' as revtype,
  rli.year,
  rli.sef as amount,
  rli.sefpaid as amtpaid,
  10000 as priority,
  rli.taxdifference,
  0 as system
from rptledgeritem rli 
  inner join rptledger rl on rli.rptledgerid = rl.objid 
where rl.state = 'APPROVED' 
and rli.sef > 0 
and rli.sefpaid < rli.sef
;




insert into rptledger_item (
  objid,
  parentid,
  rptledgerfaasid,
  remarks,
  basicav,
  sefav,
  av,
  revtype,
  year,
  amount,
  amtpaid,
  priority,
  taxdifference,
  system
)
select 
  concat(rli.objid, '-firecode') as objid,
  rli.rptledgerid as parentid,
  rli.rptledgerfaasid,
  rli.remarks,
  ifnull(rli.basicav, rli.av),
  ifnull(rli.sefav, rli.av),
  rli.av,
  'firecode' as revtype,
  rli.year,
  rli.firecode as amount,
  rli.firecodepaid as amtpaid,
  1 as priority,
  rli.taxdifference,
  0 as system
from rptledgeritem rli 
  inner join rptledger rl on rli.rptledgerid = rl.objid 
where rl.state = 'APPROVED' 
and rli.firecode > 0 
and rli.firecodepaid < rli.firecode
;



insert into rptledger_item (
  objid,
  parentid,
  rptledgerfaasid,
  remarks,
  basicav,
  sefav,
  av,
  revtype,
  year,
  amount,
  amtpaid,
  priority,
  taxdifference,
  system
)
select 
  concat(rli.objid, '-basicidle') as objid,
  rli.rptledgerid as parentid,
  rli.rptledgerfaasid,
  rli.remarks,
  ifnull(rli.basicav, rli.av),
  ifnull(rli.sefav, rli.av),
  rli.av,
  'basicidle' as revtype,
  rli.year,
  rli.basicidle as amount,
  rli.basicidlepaid as amtpaid,
  5 as priority,
  rli.taxdifference,
  0 as system
from rptledgeritem rli 
  inner join rptledger rl on rli.rptledgerid = rl.objid 
where rl.state = 'APPROVED' 
and rli.basicidle > 0 
and rli.basicidlepaid < rli.basicidle
;


insert into rptledger_item (
  objid,
  parentid,
  rptledgerfaasid,
  remarks,
  basicav,
  sefav,
  av,
  revtype,
  year,
  amount,
  amtpaid,
  priority,
  taxdifference,
  system
)
select 
  concat(rli.objid, '-sh') as objid,
  rli.rptledgerid as parentid,
  rli.rptledgerfaasid,
  rli.remarks,
  ifnull(rli.basicav, rli.av),
  ifnull(rli.sefav, rli.av),
  rli.av,
  'sh' as revtype,
  rli.year,
  rli.sh as amount,
  rli.shpaid as amtpaid,
  10 as priority,
  rli.taxdifference,
  0 as system
from rptledgeritem rli 
  inner join rptledger rl on rli.rptledgerid = rl.objid 
where rl.state = 'APPROVED' 
and rli.sh > 0 
and rli.shpaid < rli.sh
;









/*====================================================================================
*
* RPTLEDGER AND RPTBILLING RULE SUPPORT 
*
======================================================================================*/


set @ruleset = 'rptledger' 
;

delete from sys_rule_action_param where parentid in ( 
  select ra.objid 
  from sys_rule r, sys_rule_action ra 
  where r.ruleset=@ruleset and ra.parentid=r.objid 
)
;
delete from sys_rule_actiondef_param where parentid in ( 
  select ra.objid from sys_ruleset_actiondef rsa 
    inner join sys_rule_actiondef ra on ra.objid=rsa.actiondef 
  where rsa.ruleset=@ruleset
);
delete from sys_rule_actiondef where objid in ( 
  select actiondef from sys_ruleset_actiondef where ruleset=@ruleset 
);
delete from sys_rule_action where parentid in ( 
  select objid from sys_rule 
  where ruleset=@ruleset 
)
;
delete from sys_rule_condition_constraint where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset=@ruleset and rc.parentid=r.objid 
)
;
delete from sys_rule_condition_var where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset=@ruleset and rc.parentid=r.objid 
)
;
delete from sys_rule_condition where parentid in ( 
  select objid from sys_rule where ruleset=@ruleset 
)
;
delete from sys_rule_deployed where objid in ( 
  select objid from sys_rule where ruleset=@ruleset 
)
;
delete from sys_rule where ruleset=@ruleset 
;
delete from sys_ruleset_fact where ruleset=@ruleset
;
delete from sys_ruleset_actiondef where ruleset=@ruleset
;
delete from sys_rulegroup where ruleset=@ruleset 
;
delete from sys_ruleset where name=@ruleset 
;



set @ruleset = 'rptbilling' 
;

delete from sys_rule_action_param where parentid in ( 
  select ra.objid 
  from sys_rule r, sys_rule_action ra 
  where r.ruleset=@ruleset and ra.parentid=r.objid 
)
;
delete from sys_rule_actiondef_param where parentid in ( 
  select ra.objid from sys_ruleset_actiondef rsa 
    inner join sys_rule_actiondef ra on ra.objid=rsa.actiondef 
  where rsa.ruleset=@ruleset
);
delete from sys_rule_actiondef where objid in ( 
  select actiondef from sys_ruleset_actiondef where ruleset=@ruleset 
);
delete from sys_rule_action where parentid in ( 
  select objid from sys_rule 
  where ruleset=@ruleset 
)
;
delete from sys_rule_condition_constraint where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset=@ruleset and rc.parentid=r.objid 
)
;
delete from sys_rule_condition_var where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset=@ruleset and rc.parentid=r.objid 
)
;
delete from sys_rule_condition where parentid in ( 
  select objid from sys_rule where ruleset=@ruleset 
)
;
delete from sys_rule_deployed where objid in ( 
  select objid from sys_rule where ruleset=@ruleset 
)
;
delete from sys_rule where ruleset=@ruleset 
;
delete from sys_ruleset_fact where ruleset=@ruleset
;
delete from sys_ruleset_actiondef where ruleset=@ruleset
;
delete from sys_rulegroup where ruleset=@ruleset 
;
delete from sys_ruleset where name=@ruleset 
;






INSERT INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('rptbilling', 'RPT Billing Rules', 'rptbilling', 'LANDTAX', 'RULE_AUTHOR', NULL);
INSERT INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('rptledger', 'Ledger Billing Rules', 'rptledger', 'LANDTAX', 'RULE_AUTHOR', NULL);


INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('LEDGER_ITEM', 'rptledger', 'Ledger Item Posting', '1');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('TAX', 'rptledger', 'Tax Computation', '2');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_TAX', 'rptledger', 'Post Tax Computation', '3');


INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INIT', 'rptbilling', 'Init', '0');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('DISCOUNT', 'rptbilling', 'Discount Computation', '9');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_DISCOUNT', 'rptbilling', 'After Discount Computation', '10');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('PENALTY', 'rptbilling', 'Penalty Computation', '7');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_PENALTY', 'rptbilling', 'After Penalty Computation', '8');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE_SUMMARY', 'rptbilling', 'Before Summary ', '19');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'rptbilling', 'Summary', '20');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_SUMMARY', 'rptbilling', 'After Summary', '21');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BRGY_SHARE', 'rptbilling', 'Barangay Share Computation', '25');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('PROV_SHARE', 'rptbilling', 'Province Share Computation', '27');
INSERT INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('LGU_SHARE', 'rptbilling', 'LGU Share Computation', '26');






drop view if exists vw_landtax_lgu_account_mapping
; 

create view vw_landtax_lgu_account_mapping
as 
select 
  ia.org_objid as org_objid,
  ia.org_name as org_name, 
  o.orgclass as org_class, 
  p.objid as parent_objid,
  p.code as parent_code,
  p.title as parent_title,
  ia.objid as item_objid,
  ia.code as item_code,
  ia.title as item_title,
  ia.fund_objid as item_fund_objid, 
  ia.fund_code as item_fund_code,
  ia.fund_title as item_fund_title,
  ia.type as item_type,
  pt.tag as item_tag
from itemaccount ia
inner join itemaccount p on ia.parentid = p.objid 
inner join itemaccount_tag pt on p.objid = pt.acctid
inner join sys_org o on ia.org_objid = o.objid 
where p.state = 'ACTIVE'
; 









/*=============================================================
*
* COMPROMISE UPDATE 
*
==============================================================*/


CREATE TABLE `rptcompromise` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `txnno` varchar(25) NOT NULL,
  `txndate` date NOT NULL,
  `faasid` varchar(50) DEFAULT NULL,
  `rptledgerid` varchar(50) NOT NULL,
  `lastyearpaid` int(11) NOT NULL,
  `lastqtrpaid` int(11) NOT NULL,
  `startyear` int(11) NOT NULL,
  `startqtr` int(11) NOT NULL,
  `endyear` int(11) NOT NULL,
  `endqtr` int(11) NOT NULL,
  `enddate` date NOT NULL,
  `cypaymentrequired` int(11) DEFAULT NULL,
  `cypaymentorno` varchar(10) DEFAULT NULL,
  `cypaymentordate` date DEFAULT NULL,
  `cypaymentoramount` decimal(10,2) DEFAULT NULL,
  `downpaymentrequired` int(11) NOT NULL,
  `downpaymentrate` decimal(10,0) NOT NULL,
  `downpayment` decimal(10,2) NOT NULL,
  `downpaymentorno` varchar(50) DEFAULT NULL,
  `downpaymentordate` date DEFAULT NULL,
  `term` int(11) NOT NULL,
  `numofinstallment` int(11) NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `amtforinstallment` decimal(16,2) NOT NULL,
  `amtpaid` decimal(16,2) NOT NULL,
  `firstpartyname` varchar(100) NOT NULL,
  `firstpartytitle` varchar(50) NOT NULL,
  `firstpartyaddress` varchar(100) NOT NULL,
  `firstpartyctcno` varchar(15) NOT NULL,
  `firstpartyctcissued` varchar(100) NOT NULL,
  `firstpartyctcdate` date NOT NULL,
  `firstpartynationality` varchar(50) NOT NULL,
  `firstpartystatus` varchar(50) NOT NULL,
  `firstpartygender` varchar(10) NOT NULL,
  `secondpartyrepresentative` varchar(100) NOT NULL,
  `secondpartyname` varchar(100) NOT NULL,
  `secondpartyaddress` varchar(100) NOT NULL,
  `secondpartyctcno` varchar(15) NOT NULL,
  `secondpartyctcissued` varchar(100) NOT NULL,
  `secondpartyctcdate` date NOT NULL,
  `secondpartynationality` varchar(50) NOT NULL,
  `secondpartystatus` varchar(50) NOT NULL,
  `secondpartygender` varchar(10) NOT NULL,
  `dtsigned` date DEFAULT NULL,
  `notarizeddate` date DEFAULT NULL,
  `notarizedby` varchar(100) DEFAULT NULL,
  `notarizedbytitle` varchar(50) DEFAULT NULL,
  `signatories` varchar(1000) NOT NULL,
  `manualdiff` decimal(16,2) NOT NULL DEFAULT '0.00',
  `cypaymentreceiptid` varchar(50) DEFAULT NULL,
  `downpaymentreceiptid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index `ix_rptcompromise_faasid` on rptcompromise(`faasid`);
create index `ix_rptcompromise_ledgerid` on rptcompromise(`rptledgerid`);
alter table rptcompromise add CONSTRAINT `fk_rptcompromise_faas` 
  FOREIGN KEY (`faasid`) REFERENCES `faas` (`objid`);
alter table rptcompromise add CONSTRAINT `fk_rptcompromise_rptledger` 
  FOREIGN KEY (`rptledgerid`) REFERENCES `rptledger` (`objid`);



CREATE TABLE `rptcompromise_installment` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `installmentno` int(11) NOT NULL,
  `duedate` date NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `amtpaid` decimal(16,2) NOT NULL,
  `fullypaid` int(11) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


create index `ix_rptcompromise_installment_rptcompromiseid` on rptcompromise_installment(`parentid`);

alter table rptcompromise_installment 
  add CONSTRAINT `fk_rptcompromise_installment_rptcompromise` 
  FOREIGN KEY (`parentid`) REFERENCES `rptcompromise` (`objid`);



  CREATE TABLE `rptcompromise_credit` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `receiptid` varchar(50) DEFAULT NULL,
  `installmentid` varchar(50) DEFAULT NULL,
  `collector_name` varchar(100) NOT NULL,
  `collector_title` varchar(50) NOT NULL,
  `orno` varchar(10) NOT NULL,
  `ordate` date NOT NULL,
  `oramount` decimal(16,2) NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `mode` varchar(50) NOT NULL,
  `paidby` varchar(150) NOT NULL,
  `paidbyaddress` varchar(100) NOT NULL,
  `partial` int(11) DEFAULT NULL,
  `remarks` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index `ix_rptcompromise_credit_parentid` on rptcompromise_credit(`parentid`);
create index `ix_rptcompromise_credit_receiptid` on rptcompromise_credit(`receiptid`);
create index `ix_rptcompromise_credit_installmentid` on rptcompromise_credit(`installmentid`);

alter table rptcompromise_credit 
  add CONSTRAINT `fk_rptcompromise_credit_rptcompromise_installment` 
  FOREIGN KEY (`installmentid`) REFERENCES `rptcompromise_installment` (`objid`);

alter table rptcompromise_credit 
  add CONSTRAINT `fk_rptcompromise_credit_cashreceipt` 
  FOREIGN KEY (`receiptid`) REFERENCES `cashreceipt` (`objid`);

alter table rptcompromise_credit 
  add CONSTRAINT `fk_rptcompromise_credit_rptcompromise` 
  FOREIGN KEY (`parentid`) REFERENCES `rptcompromise` (`objid`);



CREATE TABLE `rptcompromise_item` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `rptledgerfaasid` varchar(50) NOT NULL,
  `revtype` varchar(50) NOT NULL,
  `revperiod` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `amtpaid` decimal(16,2) NOT NULL,
  `interest` decimal(16,2) NOT NULL,
  `interestpaid` decimal(16,2) NOT NULL,
  `priority` int(11) DEFAULT NULL,
  `taxdifference` int(11) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index `ix_rptcompromise_item_rptcompromise` on rptcompromise_item (`parentid`);
create index `ix_rptcompromise_item_rptledgerfaas` on rptcompromise_item (`rptledgerfaasid`);

alter table rptcompromise_item 
  add CONSTRAINT `fk_rptcompromise_item_rptcompromise` 
  FOREIGN KEY (`parentid`) REFERENCES `rptcompromise` (`objid`);

alter table rptcompromise_item 
  add CONSTRAINT `fk_rptcompromise_item_rptledgerfaas` 
  FOREIGN KEY (`rptledgerfaasid`) REFERENCES `rptledgerfaas` (`objid`);


/*=============================================================
*
* MIGRATE COMPROMISE RECORDS 
*
==============================================================*/
insert into rptcompromise(
    objid,
    state,
    txnno,
    txndate,
    faasid,
    rptledgerid,
    lastyearpaid,
    lastqtrpaid,
    startyear,
    startqtr,
    endyear,
    endqtr,
    enddate,
    cypaymentrequired,
    cypaymentorno,
    cypaymentordate,
    cypaymentoramount,
    downpaymentrequired,
    downpaymentrate,
    downpayment,
    downpaymentorno,
    downpaymentordate,
    term,
    numofinstallment,
    amount,
    amtforinstallment,
    amtpaid,
    firstpartyname,
    firstpartytitle,
    firstpartyaddress,
    firstpartyctcno,
    firstpartyctcissued,
    firstpartyctcdate,
    firstpartynationality,
    firstpartystatus,
    firstpartygender,
    secondpartyrepresentative,
    secondpartyname,
    secondpartyaddress,
    secondpartyctcno,
    secondpartyctcissued,
    secondpartyctcdate,
    secondpartynationality,
    secondpartystatus,
    secondpartygender,
    dtsigned,
    notarizeddate,
    notarizedby,
    notarizedbytitle,
    signatories,
    manualdiff,
    cypaymentreceiptid,
    downpaymentreceiptid
)
select 
    objid,
    state,
    txnno,
    txndate,
    faasid,
    rptledgerid,
    lastyearpaid,
    lastqtrpaid,
    startyear,
    startqtr,
    endyear,
    endqtr,
    enddate,
    cypaymentrequired,
    cypaymentorno,
    cypaymentordate,
    cypaymentoramount,
    downpaymentrequired,
    downpaymentrate,
    downpayment,
    downpaymentorno,
    downpaymentordate,
    term,
    numofinstallment,
    amount,
    amtforinstallment,
    amtpaid,
    firstpartyname,
    firstpartytitle,
    firstpartyaddress,
    firstpartyctcno,
    firstpartyctcissued,
    firstpartyctcdate,
    firstpartynationality,
    firstpartystatus,
    firstpartygender,
    secondpartyrepresentative,
    secondpartyname,
    secondpartyaddress,
    secondpartyctcno,
    secondpartyctcissued,
    secondpartyctcdate,
    secondpartynationality,
    secondpartystatus,
    secondpartygender,
    dtsigned,
    notarizeddate,
    notarizedby,
    notarizedbytitle,
    signatories,
    manualdiff,
    cypaymentreceiptid,
    downpaymentreceiptid
from rptledger_compromise
;


insert into rptcompromise_installment(
    objid,
    parentid,
    installmentno,
    duedate,
    amount,
    amtpaid,
    fullypaid
)
select 
    objid,
    rptcompromiseid,
    installmentno,
    duedate,
    amount,
    amtpaid,
    fullypaid
from rptledger_compromise_installment    
;


insert into rptcompromise_credit(
    objid,
    parentid,
    receiptid,
    installmentid,
    collector_name,
    collector_title,
    orno,
    ordate,
    oramount,
    amount, 
    mode,
    paidby,
    paidbyaddress,
    partial,
    remarks
)
select 
    objid,
    rptcompromiseid as parentid,
    rptreceiptid,
    installmentid,
    collector_name,
    collector_title,
    orno,
    ordate,
    oramount,
    oramount,
    mode,
    paidby,
    paidbyaddress,
    partial,
    remarks
from rptledger_compromise_credit    
;



insert into rptcompromise_item(
    objid,
    parentid,
    rptledgerfaasid,
    revtype,
    revperiod,
    year,
    amount,
    amtpaid,
    interest,
    interestpaid,
    priority,
    taxdifference
)
select 
    concat(min(rci.objid), '-basic') as objid,
    rci.rptcompromiseid as parentid,
    (select objid from rptledgerfaas where rptledgerid = rc.rptledgerid and rci.year >= fromyear and (rci.year <= toyear or toyear = 0) and state <> 'cancelled' limit 1) as rptledgerfaasid,
    'basic' as revtype,
    'prior' as revperiod,
    year,
    sum(rci.basic) as amount,
    sum(rci.basicpaid) as amtpaid,
    sum(rci.basicint) as interest,
    sum(rci.basicintpaid) as interestpaid,
    10000 as priority,
    0 as taxdifference
from rptledger_compromise_item rci 
inner join rptledger_compromise rc on rci.rptcompromiseid = rc.objid 
where rci.basic > 0 
group by rc.rptledgerid, year, rptcompromiseid
;



insert into rptcompromise_item(
    objid,
    parentid,
    rptledgerfaasid,
    revtype,
    revperiod,
    year,
    amount,
    amtpaid,
    interest,
    interestpaid,
    priority,
    taxdifference
)
select 
    concat(min(rci.objid), '-sef') as objid,
    rci.rptcompromiseid as parentid,
    (select objid from rptledgerfaas where rptledgerid = rc.rptledgerid and rci.year >= fromyear and (rci.year <= toyear or toyear = 0) and state <> 'cancelled' limit 1) as rptledgerfaasid,
    'sef' as revtype,
    'prior' as revperiod,
    year,
    sum(rci.sef) as amount,
    sum(rci.sefpaid) as amtpaid,
    sum(rci.sefint) as interest,
    sum(rci.sefintpaid) as interestpaid,
    10000 as priority,
    0 as taxdifference
from rptledger_compromise_item rci 
inner join rptledger_compromise rc on rci.rptcompromiseid = rc.objid 
where rci.sef > 0
group by rc.rptledgerid, year, rptcompromiseid
;


insert into rptcompromise_item(
    objid,
    parentid,
    rptledgerfaasid,
    revtype,
    revperiod,
    year,
    amount,
    amtpaid,
    interest,
    interestpaid,
    priority,
    taxdifference
)
select 
    concat(min(rci.objid), '-basicidle') as objid,
    rci.rptcompromiseid as parentid,
    (select objid from rptledgerfaas where rptledgerid = rc.rptledgerid and rci.year >= fromyear and (rci.year <= toyear or toyear = 0) and state <> 'cancelled' limit 1) as rptledgerfaasid,
    'basicidle' as revtype,
    'prior' as revperiod,
    year,
    sum(rci.basicidle) as amount,
    sum(rci.basicidlepaid) as amtpaid,
    sum(rci.basicidleint) as interest,
    sum(rci.basicidleintpaid) as interestpaid,
    10000 as priority,
    0 as taxdifference
from rptledger_compromise_item rci 
inner join rptledger_compromise rc on rci.rptcompromiseid = rc.objid 
where rci.basicidle > 0
group by rc.rptledgerid, year, rptcompromiseid
;




insert into rptcompromise_item(
    objid,
    parentid,
    rptledgerfaasid,
    revtype,
    revperiod,
    year,
    amount,
    amtpaid,
    interest,
    interestpaid,
    priority,
    taxdifference
)
select 
    concat(min(rci.objid), '-firecode') as objid,
    rci.rptcompromiseid as parentid,
    (select objid from rptledgerfaas where rptledgerid = rc.rptledgerid and rci.year >= fromyear and (rci.year <= toyear or toyear = 0) and state <> 'cancelled' limit 1) as rptledgerfaasid,
    'firecode' as revtype,
    'prior' as revperiod,
    year,
    sum(rci.firecode) as amount,
    sum(rci.firecodepaid) as amtpaid,
    sum(0) as interest,
    sum(0) as interestpaid,
    10000 as priority,
    0 as taxdifference
from rptledger_compromise_item rci 
inner join rptledger_compromise rc on rci.rptcompromiseid = rc.objid 
where rci.basicidle > 0
group by rc.rptledgerid, year, rptcompromiseid
;



/*====================================================================
*
* LANDTAX RPT DELINQUENCY UPDATE 
*
====================================================================*/

drop table if exists report_rptdelinquency_error
;
drop table if exists report_rptdelinquency_forprocess
;
drop table if exists report_rptdelinquency_item
;
drop table if exists report_rptdelinquency_barangay
;
drop table if exists report_rptdelinquency
;



CREATE TABLE `report_rptdelinquency` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `dtgenerated` datetime NOT NULL,
  `dtcomputed` datetime NOT NULL,
  `generatedby_name` varchar(255) NOT NULL,
  `generatedby_title` varchar(100) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `report_rptdelinquency_item` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `rptledgerid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `qtr` int(11) DEFAULT NULL,
  `revtype` varchar(50) NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `interest` decimal(16,2) NOT NULL,
  `discount` decimal(16,2) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_rptdelinquency foreign key(parentid)
  references report_rptdelinquency(objid)
;

create index fk_rptdelinquency_item_rptdelinquency2 on report_rptdelinquency_item(parentid)  
;


alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_rptledger foreign key(rptledgerid)
  references rptledger(objid)
;

create index fk_rptdelinquency_item_rptledger2 on report_rptdelinquency_item(rptledgerid)  
;

alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_barangay foreign key(barangayid)
  references barangay(objid)
;

create index fk_rptdelinquency_item_barangay2 on report_rptdelinquency_item(barangayid)  
;




CREATE TABLE `report_rptdelinquency_barangay` (
  objid varchar(50) not null, 
  parentid varchar(50) not null, 
  `barangayid` varchar(50) NOT NULL,
  count int not null,
  processed int not null, 
  errors int not null, 
  ignored int not null, 
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


alter table report_rptdelinquency_barangay 
  add constraint fk_rptdelinquency_barangay_rptdelinquency foreign key(parentid)
  references report_rptdelinquency(objid)
;

create index fk_rptdelinquency_barangay_rptdelinquency on report_rptdelinquency_item(parentid)  
;


alter table report_rptdelinquency_barangay 
  add constraint fk_rptdelinquency_barangay_barangay foreign key(barangayid)
  references barangay(objid)
;

create index fk_rptdelinquency_barangay_barangay2 on report_rptdelinquency_barangay(barangayid)  
;


CREATE TABLE `report_rptdelinquency_forprocess` (
  `objid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index ix_barangayid on report_rptdelinquency_forprocess(barangayid);
  


CREATE TABLE `report_rptdelinquency_error` (
  `objid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  `error` text NULL,
  `ignored` int,
  PRIMARY KEY (`objid`),
  KEY `ix_barangayid` (`barangayid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;  




drop view vw_landtax_report_rptdelinquency_detail
;

create view vw_landtax_report_rptdelinquency_detail 
as
select
  parentid, 
  rptledgerid,
  barangayid,
  year,
  qtr,
  case when revtype = 'basic' then amount else 0 end as basic,
  case when revtype = 'basic' then interest else 0 end as basicint,
  case when revtype = 'basic' then discount else 0 end as basicdisc,
  case when revtype = 'basic' then interest - discount else 0 end as basicdp,
  case when revtype = 'basic' then amount + interest - discount else 0 end as basicnet,
  case when revtype = 'basicidle' then amount else 0 end as basicidle,
  case when revtype = 'basicidle' then interest else 0 end as basicidleint,
  case when revtype = 'basicidle' then discount else 0 end as basicidledisc,
  case when revtype = 'basicidle' then interest - discount else 0 end as basicidledp,
  case when revtype = 'basicidle' then amount + interest - discount else 0 end as basicidlenet,
  case when revtype = 'sef' then amount else 0 end as sef,
  case when revtype = 'sef' then interest else 0 end as sefint,
  case when revtype = 'sef' then discount else 0 end as sefdisc,
  case when revtype = 'sef' then interest - discount else 0 end as sefdp,
  case when revtype = 'sef' then amount + interest - discount else 0 end as sefnet,
  case when revtype = 'firecode' then amount else 0 end as firecode,
  case when revtype = 'firecode' then interest else 0 end as firecodeint,
  case when revtype = 'firecode' then discount else 0 end as firecodedisc,
  case when revtype = 'firecode' then interest - discount else 0 end as firecodedp,
  case when revtype = 'firecode' then amount + interest - discount else 0 end as firecodenet,
  case when revtype = 'sh' then amount else 0 end as sh,
  case when revtype = 'sh' then interest else 0 end as shint,
  case when revtype = 'sh' then discount else 0 end as shdisc,
  case when revtype = 'sh' then interest - discount else 0 end as shdp,
  case when revtype = 'sh' then amount + interest - discount else 0 end as shnet,
  amount + interest - discount as total
from report_rptdelinquency_item 
;



/*====================================================================
*
* LANDTAX RPT DELINQUENCY UPDATE 
*
====================================================================*/

drop table if exists report_rptdelinquency_error
;
drop table if exists report_rptdelinquency_forprocess
;
drop table if exists report_rptdelinquency_item
;
drop table if exists report_rptdelinquency_barangay
;
drop table if exists report_rptdelinquency
;



CREATE TABLE `report_rptdelinquency` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `dtgenerated` datetime NOT NULL,
  `dtcomputed` datetime NOT NULL,
  `generatedby_name` varchar(255) NOT NULL,
  `generatedby_title` varchar(100) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `report_rptdelinquency_item` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `rptledgerid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `qtr` int(11) DEFAULT NULL,
  `revtype` varchar(50) NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `interest` decimal(16,2) NOT NULL,
  `discount` decimal(16,2) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_rptdelinquency foreign key(parentid)
  references report_rptdelinquency(objid)
;

create index fk_rptdelinquency_item_rptdelinquency2 on report_rptdelinquency_item(parentid)  
;


alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_rptledger foreign key(rptledgerid)
  references rptledger(objid)
;

create index fk_rptdelinquency_item_rptledger2 on report_rptdelinquency_item(rptledgerid)  
;

alter table report_rptdelinquency_item 
  add constraint fk_rptdelinquency_item_barangay foreign key(barangayid)
  references barangay(objid)
;

create index fk_rptdelinquency_item_barangay2 on report_rptdelinquency_item(barangayid)  
;




CREATE TABLE `report_rptdelinquency_barangay` (
  objid varchar(50) not null, 
  parentid varchar(50) not null, 
  `barangayid` varchar(50) NOT NULL,
  count int not null,
  processed int not null, 
  errors int not null, 
  ignored int not null, 
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


alter table report_rptdelinquency_barangay 
  add constraint fk_rptdelinquency_barangay_rptdelinquency foreign key(parentid)
  references report_rptdelinquency(objid)
;

create index fk_rptdelinquency_barangay_rptdelinquency on report_rptdelinquency_item(parentid)  
;


alter table report_rptdelinquency_barangay 
  add constraint fk_rptdelinquency_barangay_barangay foreign key(barangayid)
  references barangay(objid)
;

create index fk_rptdelinquency_barangay_barangay2 on report_rptdelinquency_barangay(barangayid)  
;


CREATE TABLE `report_rptdelinquency_forprocess` (
  `objid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index ix_barangayid on report_rptdelinquency_forprocess(barangayid);
  


CREATE TABLE `report_rptdelinquency_error` (
  `objid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  `error` text NULL,
  `ignored` int,
  PRIMARY KEY (`objid`),
  KEY `ix_barangayid` (`barangayid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;  




drop view vw_landtax_report_rptdelinquency_detail
;

create view vw_landtax_report_rptdelinquency_detail 
as
select
  parentid, 
  rptledgerid,
  barangayid,
  year,
  qtr,
  case when revtype = 'basic' then amount else 0 end as basic,
  case when revtype = 'basic' then interest else 0 end as basicint,
  case when revtype = 'basic' then discount else 0 end as basicdisc,
  case when revtype = 'basic' then interest - discount else 0 end as basicdp,
  case when revtype = 'basic' then amount + interest - discount else 0 end as basicnet,
  case when revtype = 'basicidle' then amount else 0 end as basicidle,
  case when revtype = 'basicidle' then interest else 0 end as basicidleint,
  case when revtype = 'basicidle' then discount else 0 end as basicidledisc,
  case when revtype = 'basicidle' then interest - discount else 0 end as basicidledp,
  case when revtype = 'basicidle' then amount + interest - discount else 0 end as basicidlenet,
  case when revtype = 'sef' then amount else 0 end as sef,
  case when revtype = 'sef' then interest else 0 end as sefint,
  case when revtype = 'sef' then discount else 0 end as sefdisc,
  case when revtype = 'sef' then interest - discount else 0 end as sefdp,
  case when revtype = 'sef' then amount + interest - discount else 0 end as sefnet,
  case when revtype = 'firecode' then amount else 0 end as firecode,
  case when revtype = 'firecode' then interest else 0 end as firecodeint,
  case when revtype = 'firecode' then discount else 0 end as firecodedisc,
  case when revtype = 'firecode' then interest - discount else 0 end as firecodedp,
  case when revtype = 'firecode' then amount + interest - discount else 0 end as firecodenet,
  case when revtype = 'sh' then amount else 0 end as sh,
  case when revtype = 'sh' then interest else 0 end as shint,
  case when revtype = 'sh' then discount else 0 end as shdisc,
  case when revtype = 'sh' then interest - discount else 0 end as shdp,
  case when revtype = 'sh' then amount + interest - discount else 0 end as shnet,
  amount + interest - discount as total
from report_rptdelinquency_item 
;





drop  view if exists vw_landtax_report_rptdelinquency
;

create view vw_landtax_report_rptdelinquency
as
select
  v.rptledgerid,
  v.barangayid,
  v.year,
  v.qtr,
  rr.dtgenerated,
  rr.generatedby_name,
  rr.generatedby_title,
  sum(v.basic) as basic,
  sum(v.basicint) as basicint,
  sum(v.basicdisc) as basicdisc,
  sum(v.basicdp) as basicdp,
  sum(v.basicnet) as basicnet,
  sum(v.basicidle) as basicidle,
  sum(v.basicidleint) as basicidleint,
  sum(v.basicidledisc) as basicidledisc,
  sum(v.basicidledp) as basicidledp,
  sum(v.basicidlenet) as basicidlenet,
  sum(v.sef) as sef,
  sum(v.sefint) as sefint,
  sum(v.sefdisc) as sefdisc,
  sum(v.sefdp) as sefdp,
  sum(v.sefnet) as sefnet,
  sum(v.firecode) as firecode,
  sum(v.firecodeint) as firecodeint,
  sum(v.firecodedisc) as firecodedisc,
  sum(v.firecodedp) as firecodedp,
  sum(v.firecodenet) as firecodenet,
  sum(v.sh) as sh,
  sum(v.shint) as shint,
  sum(v.shdisc) as shdisc,
  sum(v.shdp) as shdp,
  sum(v.shnet) as shnet,
  sum(v.total) as total
from report_rptdelinquency rr 
inner join vw_landtax_report_rptdelinquency_detail v on rr.objid = v.parentid 
group by 
  v.rptledgerid,
  v.barangayid,
  v.year,
  v.qtr,
  rr.dtgenerated,
  rr.generatedby_name,
  rr.generatedby_title
;



drop  view vw_landtax_report_rptdelinquency
;

create view vw_landtax_report_rptdelinquency
as
select
  v.rptledgerid,
  v.barangayid,
  v.year,
  v.qtr,
  rr.dtgenerated,
  rr.generatedby_name,
  rr.generatedby_title,
  sum(v.basic) as basic,
  sum(v.basicint) as basicint,
  sum(v.basicdisc) as basicdisc,
  sum(v.basicdp) as basicdp,
  sum(v.basicnet) as basicnet,
  sum(v.basicidle) as basicidle,
  sum(v.basicidleint) as basicidleint,
  sum(v.basicidledisc) as basicidledisc,
  sum(v.basicidledp) as basicidledp,
  sum(v.basicidlenet) as basicidlenet,
  sum(v.sef) as sef,
  sum(v.sefint) as sefint,
  sum(v.sefdisc) as sefdisc,
  sum(v.sefdp) as sefdp,
  sum(v.sefnet) as sefnet,
  sum(v.firecode) as firecode,
  sum(v.firecodeint) as firecodeint,
  sum(v.firecodedisc) as firecodedisc,
  sum(v.firecodedp) as firecodedp,
  sum(v.firecodenet) as firecodenet,
  sum(v.sh) as sh,
  sum(v.shint) as shint,
  sum(v.shdisc) as shdisc,
  sum(v.shdp) as shdp,
  sum(v.shnet) as shnet,
  sum(v.total) as total
from report_rptdelinquency rr 
inner join vw_landtax_report_rptdelinquency_detail v on rr.objid = v.parentid 
group by 
  v.rptledgerid,
  v.barangayid,
  v.year,
  v.qtr,
  rr.dtgenerated,
  rr.generatedby_name,
  rr.generatedby_title
;




/*REVENUE PARENT ACCOUNTS  */

INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_ADVANCE', 'APPROVED', '588-007', 'RPT BASIC ADVANCE', 'RPT BASIC ADVANCE', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_CURRENT', 'APPROVED', '588-001', 'RPT BASIC CURRENT', 'RPT BASIC CURRENT', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_CURRENT', 'APPROVED', '588-004', 'RPT BASIC PENALTY CURRENT', 'RPT BASIC PENALTY CURRENT', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_PREVIOUS', 'APPROVED', '588-002', 'RPT BASIC PREVIOUS', 'RPT BASIC PREVIOUS', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_PREVIOUS', 'APPROVED', '588-005', 'RPT BASIC PENALTY PREVIOUS', 'RPT BASIC PENALTY PREVIOUS', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_PRIOR', 'APPROVED', '588-003', 'RPT BASIC PRIOR', 'RPT BASIC PRIOR', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_PRIOR', 'APPROVED', '588-006', 'RPT BASIC PENALTY PRIOR', 'RPT BASIC PENALTY PRIOR', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;

INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEF_ADVANCE', 'APPROVED', '455-050', 'RPT SEF ADVANCE', 'RPT SEF ADVANCE', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEF_CURRENT', 'APPROVED', '455-050', 'RPT SEF CURRENT', 'RPT SEF CURRENT', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEFINT_CURRENT', 'APPROVED', '455-050', 'RPT SEF PENALTY CURRENT', 'RPT SEF PENALTY CURRENT', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEF_PREVIOUS', 'APPROVED', '455-050', 'RPT SEF PREVIOUS', 'RPT SEF PREVIOUS', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEFINT_PREVIOUS', 'APPROVED', '455-050', 'RPT SEF PENALTY PREVIOUS', 'RPT SEF PENALTY PREVIOUS', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEF_PRIOR', 'APPROVED', '455-050', 'RPT SEF PRIOR', 'RPT SEF PRIOR', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_SEFINT_PRIOR', 'APPROVED', '455-050', 'RPT SEF PENALTY PRIOR', 'RPT SEF PENALTY PRIOR', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL)
;





insert into itemaccount_tag (objid, acctid, tag)
select  'RPT_BASIC_ADVANCE' as objid, 'RPT_BASIC_ADVANCE' as acctid, 'rpt_basic_advance' as tag
union 
select  'RPT_BASIC_CURRENT' as objid, 'RPT_BASIC_CURRENT' as acctid, 'rpt_basic_current' as tag
union 
select  'RPT_BASICINT_CURRENT' as objid, 'RPT_BASICINT_CURRENT' as acctid, 'rpt_basicint_current' as tag
union 
select  'RPT_BASIC_PREVIOUS' as objid, 'RPT_BASIC_PREVIOUS' as acctid, 'rpt_basic_previous' as tag
union 
select  'RPT_BASICINT_PREVIOUS' as objid, 'RPT_BASICINT_PREVIOUS' as acctid, 'rpt_basicint_previous' as tag
union 
select  'RPT_BASIC_PRIOR' as objid, 'RPT_BASIC_PRIOR' as acctid, 'rpt_basic_prior' as tag
union 
select  'RPT_BASICINT_PRIOR' as objid, 'RPT_BASICINT_PRIOR' as acctid, 'rpt_basicint_prior' as tag
union 
select  'RPT_SEF_ADVANCE' as objid, 'RPT_SEF_ADVANCE' as acctid, 'rpt_sef_advance' as tag
union 
select  'RPT_SEF_CURRENT' as objid, 'RPT_SEF_CURRENT' as acctid, 'rpt_sef_current' as tag
union 
select  'RPT_SEFINT_CURRENT' as objid, 'RPT_SEFINT_CURRENT' as acctid, 'rpt_sefint_current' as tag
union 
select  'RPT_SEF_PREVIOUS' as objid, 'RPT_SEF_PREVIOUS' as acctid, 'rpt_sef_previous' as tag
union 
select  'RPT_SEFINT_PREVIOUS' as objid, 'RPT_SEFINT_PREVIOUS' as acctid, 'rpt_sefint_previous' as tag
union 
select  'RPT_SEF_PRIOR' as objid, 'RPT_SEF_PRIOR' as acctid, 'rpt_sef_prior' as tag
union 
select  'RPT_SEFINT_PRIOR' as objid, 'RPT_SEFINT_PRIOR' as acctid, 'rpt_sefint_prior' as tag
;





/* BARANGAY SHARE PAYABLE */

INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC ADVANCE BARANGAY SHARE', 'RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC CURRENT BARANGAY SHARE', 'RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC PREVIOUS BARANGAY SHARE', 'RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC PRIOR BARANGAY SHARE', 'RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;
INSERT INTO itemaccount (objid, state, code, title, description, type, fund_objid, fund_code, fund_title, defaultvalue, valuetype, org_objid, org_name, parentid) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE', 'APPROVED', '455-049', 'RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL)
;



insert into itemaccount_tag (objid, acctid, tag)
select  'RPT_BASIC_ADVANCE_BRGY_SHARE' as objid, 'RPT_BASIC_ADVANCE_BRGY_SHARE' as acctid, 'rpt_basic_advance' as tag
union 
select  'RPT_BASIC_CURRENT_BRGY_SHARE' as objid, 'RPT_BASIC_CURRENT_BRGY_SHARE' as acctid, 'rpt_basic_current' as tag
union 
select  'RPT_BASICINT_CURRENT_BRGY_SHARE' as objid, 'RPT_BASICINT_CURRENT_BRGY_SHARE' as acctid, 'rpt_basicint_current' as tag
union 
select  'RPT_BASIC_PREVIOUS_BRGY_SHARE' as objid, 'RPT_BASIC_PREVIOUS_BRGY_SHARE' as acctid, 'rpt_basic_previous' as tag
union 
select  'RPT_BASICINT_PREVIOUS_BRGY_SHARE' as objid, 'RPT_BASICINT_PREVIOUS_BRGY_SHARE' as acctid, 'rpt_basicint_previous' as tag
union 
select  'RPT_BASIC_PRIOR_BRGY_SHARE' as objid, 'RPT_BASIC_PRIOR_BRGY_SHARE' as acctid, 'rpt_basic_prior' as tag
union 
select  'RPT_BASICINT_PRIOR_BRGY_SHARE' as objid, 'RPT_BASICINT_PRIOR_BRGY_SHARE' as acctid, 'rpt_basicint_prior' as tag
;






/* PROVINCE SHARE PAYABLE */

INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASIC_ADVANCE_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC ADVANCE PROVINCE SHARE', 'RPT BASIC ADVANCE PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASIC_CURRENT_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC CURRENT PROVINCE SHARE', 'RPT BASIC CURRENT PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASICINT_CURRENT_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC CURRENT PENALTY PROVINCE SHARE', 'RPT BASIC CURRENT PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASIC_PREVIOUS_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC PREVIOUS PROVINCE SHARE', 'RPT BASIC PREVIOUS PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASICINT_PREVIOUS_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC PREVIOUS PENALTY PROVINCE SHARE', 'RPT BASIC PREVIOUS PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASIC_PRIOR_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC PRIOR PROVINCE SHARE', 'RPT BASIC PRIOR PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_BASICINT_PRIOR_PROVINCE_SHARE', 'APPROVED', '455-049', 'RPT BASIC PRIOR PENALTY PROVINCE SHARE', 'RPT BASIC PRIOR PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', NULL, NULL, NULL);

INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEF_ADVANCE_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF ADVANCE PROVINCE SHARE', 'RPT SEF ADVANCE PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEF_CURRENT_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF CURRENT PROVINCE SHARE', 'RPT SEF CURRENT PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEFINT_CURRENT_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF CURRENT PENALTY PROVINCE SHARE', 'RPT SEF CURRENT PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEF_PREVIOUS_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF PREVIOUS PROVINCE SHARE', 'RPT SEF PREVIOUS PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEFINT_PREVIOUS_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF PREVIOUS PENALTY PROVINCE SHARE', 'RPT SEF PREVIOUS PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEF_PRIOR_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF PRIOR PROVINCE SHARE', 'RPT SEF PRIOR PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`) 
VALUES ('RPT_SEFINT_PRIOR_PROVINCE_SHARE', 'APPROVED', '455-050', 'RPT SEF PRIOR PENALTY PROVINCE SHARE', 'RPT SEF PRIOR PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', NULL, NULL, NULL);



insert into itemaccount_tag (objid, acctid, tag)
select  'RPT_BASIC_ADVANCE_PROVINCE_SHARE' as objid, 'RPT_BASIC_ADVANCE_PROVINCE_SHARE' as acctid, 'rpt_basic_advance' as tag
union 
select  'RPT_BASIC_CURRENT_PROVINCE_SHARE' as objid, 'RPT_BASIC_CURRENT_PROVINCE_SHARE' as acctid, 'rpt_basic_current' as tag
union 
select  'RPT_BASICINT_CURRENT_PROVINCE_SHARE' as objid, 'RPT_BASICINT_CURRENT_PROVINCE_SHARE' as acctid, 'rpt_basicint_current' as tag
union 
select  'RPT_BASIC_PREVIOUS_PROVINCE_SHARE' as objid, 'RPT_BASIC_PREVIOUS_PROVINCE_SHARE' as acctid, 'rpt_basic_previous' as tag
union 
select  'RPT_BASICINT_PREVIOUS_PROVINCE_SHARE' as objid, 'RPT_BASICINT_PREVIOUS_PROVINCE_SHARE' as acctid, 'rpt_basicint_previous' as tag
union 
select  'RPT_BASIC_PRIOR_PROVINCE_SHARE' as objid, 'RPT_BASIC_PRIOR_PROVINCE_SHARE' as acctid, 'rpt_basic_prior' as tag
union 
select  'RPT_BASICINT_PRIOR_PROVINCE_SHARE' as objid, 'RPT_BASICINT_PRIOR_PROVINCE_SHARE' as acctid, 'rpt_basicint_prior' as tag
union 
select  'RPT_SEF_ADVANCE_PROVINCE_SHARE' as objid, 'RPT_SEF_ADVANCE_PROVINCE_SHARE' as acctid, 'rpt_sef_advance' as tag
union 
select  'RPT_SEF_CURRENT_PROVINCE_SHARE' as objid, 'RPT_SEF_CURRENT_PROVINCE_SHARE' as acctid, 'rpt_sef_current' as tag
union 
select  'RPT_SEFINT_CURRENT_PROVINCE_SHARE' as objid, 'RPT_SEFINT_CURRENT_PROVINCE_SHARE' as acctid, 'rpt_sefint_current' as tag
union 
select  'RPT_SEF_PREVIOUS_PROVINCE_SHARE' as objid, 'RPT_SEF_PREVIOUS_PROVINCE_SHARE' as acctid, 'rpt_sef_previous' as tag
union 
select  'RPT_SEFINT_PREVIOUS_PROVINCE_SHARE' as objid, 'RPT_SEFINT_PREVIOUS_PROVINCE_SHARE' as acctid, 'rpt_sefint_previous' as tag
union 
select  'RPT_SEF_PRIOR_PROVINCE_SHARE' as objid, 'RPT_SEF_PRIOR_PROVINCE_SHARE' as acctid, 'rpt_sef_prior' as tag
union 
select  'RPT_SEFINT_PRIOR_PROVINCE_SHARE' as objid, 'RPT_SEFINT_PRIOR_PROVINCE_SHARE' as acctid, 'rpt_sefint_prior' as tag;




/*===============================================================
*
* SET PARENT OF MUNICIPAL ACCOUNTS
*
===============================================================*/


-- advance account 
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_ADVANCE', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basicadvacct_objid = i.objid 
and m.lguid = o.objid
;


-- current account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_CURRENT', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basiccurracct_objid = i.objid 
and m.lguid = o.objid
;

-- current int account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_CURRENT', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basiccurrintacct_objid = i.objid 
and m.lguid = o.objid
;



-- prior account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_PRIOR', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basicprioracct_objid = i.objid 
and m.lguid = o.objid
;

-- priorint account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_PRIOR', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basicpriorintacct_objid = i.objid 
and m.lguid = o.objid
;



-- previous account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_PREVIOUS', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basicprevacct_objid = i.objid 
and m.lguid = o.objid
;



-- prevint account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_PREVIOUS', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.basicprevintacct_objid = i.objid 
and m.lguid = o.objid
;




-- advance account 
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEF_ADVANCE', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefadvacct_objid = i.objid 
and m.lguid = o.objid
;


-- current account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEF_CURRENT', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefcurracct_objid = i.objid 
and m.lguid = o.objid
;

-- current int account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEFINT_CURRENT', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefcurrintacct_objid = i.objid 
and m.lguid = o.objid
;



-- prior account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEF_PRIOR', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefprioracct_objid = i.objid 
and m.lguid = o.objid
;

-- priorint account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEFINT_PRIOR', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefpriorintacct_objid = i.objid 
and m.lguid = o.objid
;



-- previous account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEF_PREVIOUS', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefprevacct_objid = i.objid 
and m.lguid = o.objid
;



-- prevint account
update itemaccount i, municipality_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_SEFINT_PREVIOUS', 
	i.org_objid = m.lguid,
	i.org_name = o.name 
where m.sefprevintacct_objid = i.objid 
and m.lguid = o.objid
;



/*===============================================================
*
* SET PARENT OF PROVINCE ACCOUNTS
*
===============================================================*/
-- advance account 
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASIC_ADVANCE_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basicadvacct_objid = i.objid 
and p.objid = o.objid
;


-- current account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASIC_CURRENT_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basiccurracct_objid = i.objid 
and p.objid = o.objid
;

-- current int account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASICINT_CURRENT_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basiccurrintacct_objid = i.objid 
and p.objid = o.objid
;




-- prior account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASIC_PRIOR_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basicprioracct_objid = i.objid 
and p.objid = o.objid
;

-- priorint account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASICINT_PRIOR_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basicpriorintacct_objid = i.objid 
and p.objid = o.objid
;


-- previous account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASIC_PREVIOUS_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basicprevacct_objid = i.objid 
and p.objid = o.objid
;



-- prevint account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_BASICINT_PREVIOUS_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.basicprevintacct_objid = i.objid 
and p.objid = o.objid
;



-- advance account 
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEF_ADVANCE_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefadvacct_objid = i.objid 
and p.objid = o.objid
;


-- current account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEF_CURRENT_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefcurracct_objid = i.objid 
and p.objid = o.objid
;

-- current int account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEFINT_CURRENT_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefcurrintacct_objid = i.objid 
and p.objid = o.objid
;




-- prior account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEF_PRIOR_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefprioracct_objid = i.objid 
and p.objid = o.objid
;

-- priorint account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEFINT_PRIOR_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefpriorintacct_objid = i.objid 
and p.objid = o.objid
;


-- previous account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEF_PREVIOUS_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefprevacct_objid = i.objid 
and p.objid = o.objid
;



-- prevint account
update itemaccount i, province_taxaccount_mapping p, sys_org o set 
	i.parentid = 'RPT_SEFINT_PREVIOUS_PROVINCE_SHARE', 
	i.org_objid = p.objid,
	i.org_name = o.name 
where p.sefprevintacct_objid = i.objid 
and p.objid = o.objid
;





/*===============================================================
*
* SET PARENT OF BARANGAY ACCOUNTS
*
===============================================================*/

-- advance account 
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_ADVANCE_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basicadvacct_objid = i.objid 
and m.barangayid = o.objid
;


-- current account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_CURRENT_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basiccurracct_objid = i.objid 
and m.barangayid = o.objid
;

-- current int account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_CURRENT_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basiccurrintacct_objid = i.objid 
and m.barangayid = o.objid
;




-- prior account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_PRIOR_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basicprioracct_objid = i.objid 
and m.barangayid = o.objid
;

-- priorint account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_PRIOR_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basicpriorintacct_objid = i.objid 
and m.barangayid = o.objid
;


-- previous account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASIC_PREVIOUS_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basicprevacct_objid = i.objid 
and m.barangayid = o.objid
;



-- prevint account
update itemaccount i, brgy_taxaccount_mapping m, sys_org o set 
	i.parentid = 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', 
	i.org_objid = m.barangayid,
	i.org_name = o.name 
where m.basicprevintacct_objid = i.objid 
and m.barangayid = o.objid
;



update itemaccount set state = 'ACTIVE' where state = 'APPROVED' and objid like 'RPT_%'
;


/* 03021 */

/*============================================
*
* TAX DIFFERENCE
*
*============================================*/

CREATE TABLE `rptledger_avdifference` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `rptledgerfaas_objid` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `av` decimal(16,2) NOT NULL,
  `paid` int(11) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create index `fk_rptledger` on rptledger_avdifference (`parent_objid`)
;

create index `fk_rptledgerfaas` on rptledger_avdifference (`rptledgerfaas_objid`)
;
 
alter table rptledger_avdifference 
	add CONSTRAINT `fk_rptledgerfaas` FOREIGN KEY (`rptledgerfaas_objid`) 
	REFERENCES `rptledgerfaas` (`objid`)
;

alter table rptledger_avdifference 
	add CONSTRAINT `fk_rptledger` FOREIGN KEY (`parent_objid`) 
	REFERENCES `rptledger` (`objid`)
;



create view vw_rptledger_avdifference
as 
select 
  rlf.objid,
  'APPROVED' as state,
  d.parent_objid as rptledgerid,
  rl.faasid,
  rl.tdno,
  rlf.txntype_objid,
  rlf.classification_objid,
  rlf.actualuse_objid,
  rlf.taxable,
  rlf.backtax,
  d.year as fromyear,
  1 as fromqtr,
  d.year as toyear,
  4 as toqtr,
  d.av as assessedvalue,
  1 as systemcreated,
  rlf.reclassed,
  rlf.idleland,
  1 as taxdifference
from rptledger_avdifference d 
inner join rptledgerfaas rlf on d.rptledgerfaas_objid = rlf.objid 
inner join rptledger rl on d.parent_objid = rl.objid 
; 

/* 03022 */

/*============================================
*
* SYNC PROVINCE AND REMOTE LEGERS
*
*============================================*/
drop table if exists `rptledger_remote`;
drop table if exists `remote_mapping`;

CREATE TABLE `remote_mapping` (
  `objid` varchar(50) NOT NULL,
  `doctype` varchar(50) NOT NULL,
  `remote_objid` varchar(50) NOT NULL,
  `createdby_name` varchar(255) NOT NULL,
  `createdby_title` varchar(100) DEFAULT NULL,
  `dtcreated` datetime NOT NULL,
  `orgcode` varchar(10) DEFAULT NULL,
  `remote_orgcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


create index ix_doctype on remote_mapping(doctype);
create index ix_orgcode on remote_mapping(orgcode);
create index ix_remote_orgcode on remote_mapping(remote_orgcode);
create index ix_remote_objid on remote_mapping(remote_objid);




drop table if exists sync_data_forprocess;
drop table if exists sync_data_pending;
drop table if exists sync_data;


create table `sync_data` (
  `objid` varchar(50) not null,
  `parentid` varchar(50) not null,
  `refid` varchar(50) not null,
  `reftype` varchar(50) not null,
  `action` varchar(50) not null,
  `orgid` varchar(50) null,
  `remote_orgid` varchar(50) null,
  `remote_orgcode` varchar(20) null,
  `remote_orgclass` varchar(20) null,
  `dtfiled` datetime not null,
  `idx` int not null,
  `sender_objid` varchar(50) null,
  `sender_name` varchar(150) null,
  primary key (`objid`)
) engine=innodb default charset=utf8
;


create index ix_sync_data_refid on sync_data(refid)
;

create index ix_sync_data_reftype on sync_data(reftype)
;

create index ix_sync_data_orgid on sync_data(orgid)
;

create index ix_sync_data_dtfiled on sync_data(dtfiled)
;



CREATE TABLE `sync_data_forprocess` (
  `objid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table sync_data_forprocess add constraint `fk_sync_data_forprocess_sync_data` 
  foreign key (`objid`) references `sync_data` (`objid`)
;

CREATE TABLE `sync_data_pending` (
  `objid` varchar(50) NOT NULL,
  `error` text,
  `expirydate` datetime,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


alter table sync_data_pending add constraint `fk_sync_data_pending_sync_data` 
  foreign key (`objid`) references `sync_data` (`objid`)
;

create index ix_expirydate on sync_data_pending(expirydate)
;








/*==================================================
*
*  BATCH GR UPDATES
*
=====================================================*/
drop view if exists vw_batchgr_error;
drop table if exists batchgr_log;
drop table if exists batchgr_error;
drop table if exists batchgr_items_forrevision;
drop table if exists batchgr_forprocess;
drop table if exists batchgr_item;
drop table if exists batchgr;


CREATE TABLE `batchgr` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `ry` int(255) NOT NULL,
  `lgu_objid` varchar(50) NOT NULL,
  `barangay_objid` varchar(50) NOT NULL,
  `rputype` varchar(15) DEFAULT NULL,
  `classification_objid` varchar(50) DEFAULT NULL,
  `section` varchar(10) DEFAULT NULL,
  `memoranda` varchar(100) DEFAULT NULL,
  `appraiser_name` varchar(150) DEFAULT NULL,
  `appraiser_dtsigned` date DEFAULT NULL,
  `taxmapper_name` varchar(150) DEFAULT NULL,
  `taxmapper_dtsigned` date DEFAULT NULL,
  `recommender_name` varchar(150) DEFAULT NULL,
  `recommender_dtsigned` date DEFAULT NULL,
  `approver_name` varchar(150) DEFAULT NULL,
  `approver_dtsigned` date DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


create index `ix_barangay_objid` on batchgr(`barangay_objid`);
create index `ix_state` on batchgr(`state`);
create index `fk_lgu_objid` on batchgr(`lgu_objid`);


alter table batchgr add constraint `fk_batchgr_barangay_objid` 
  foreign key (`barangay_objid`) references `barangay` (`objid`);
  
alter table batchgr add constraint `fk_batchgr_lgu_objid` 
  foreign key (`lgu_objid`) references `sys_org` (`objid`);



CREATE TABLE `batchgr_item` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `rputype` varchar(15) NOT NULL,
  `tdno` varchar(50) NOT NULL,
  `fullpin` varchar(50) NOT NULL,
  `pin` varchar(50) NOT NULL,
  `suffix` int(255) NOT NULL,
  `newfaasid` varchar(50) DEFAULT NULL,
  `error` text,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create index `fk_batchgr_item_batchgr` on batchgr_item (`parent_objid`);
create index `fk_batchgr_item_newfaasid` on batchgr_item (`newfaasid`);
create index `fk_batchgr_item_tdno` on batchgr_item (`tdno`);
create index `fk_batchgr_item_pin` on batchgr_item (`pin`);


alter table batchgr_item add constraint `fk_batchgr_item_objid` 
  foreign key (`objid`) references `faas` (`objid`);

alter table batchgr_item add constraint `fk_batchgr_item_batchgr` 
  foreign key (`parent_objid`) references `batchgr` (`objid`);

alter table batchgr_item add constraint `fk_batchgr_item_newfaasid` 
  foreign key (`newfaasid`) references `faas` (`objid`);




alter table faas modify column prevtdno varchar(1000);

create index ix_prevtdno on faas(prevtdno);






create view vw_txn_log 
as 
select 
  distinct
  u.objid as userid, 
  u.name as username, 
  txndate, 
  ref,
  action, 
  1 as cnt 
from txnlog t
inner join sys_user u on t.userid = u.objid 

union 

select 
  u.objid as userid, 
  u.name as username,
  t.enddate as txndate, 
  'faas' as ref,
  case 
    when t.state like '%receiver%' then 'receive'
    when t.state like '%examiner%' then 'examine'
    when t.state like '%taxmapper_chief%' then 'approve taxmap'
    when t.state like '%taxmapper%' then 'taxmap'
    when t.state like '%appraiser%' then 'appraise'
    when t.state like '%appraiser_chief%' then 'approve appraisal'
    when t.state like '%recommender%' then 'recommend'
    when t.state like '%approver%' then 'approve'
    else t.state 
  end action, 
  1 as cnt 
from faas_task t 
inner join sys_user u on t.actor_objid = u.objid 
where t.state not like '%assign%'

union 

select 
  u.objid as userid, 
  u.name as username,
  t.enddate as txndate, 
  'subdivision' as ref,
  case 
    when t.state like '%receiver%' then 'receive'
    when t.state like '%examiner%' then 'examine'
    when t.state like '%taxmapper_chief%' then 'approve taxmap'
    when t.state like '%taxmapper%' then 'taxmap'
    when t.state like '%appraiser%' then 'appraise'
    when t.state like '%appraiser_chief%' then 'approve appraisal'
    when t.state like '%recommender%' then 'recommend'
    when t.state like '%approver%' then 'approve'
    else t.state 
  end action, 
  1 as cnt 
from subdivision_task t 
inner join sys_user u on t.actor_objid = u.objid 
where t.state not like '%assign%'

union 

select 
  u.objid as userid, 
  u.name as username,
  t.enddate as txndate, 
  'consolidation' as ref,
  case 
    when t.state like '%receiver%' then 'receive'
    when t.state like '%examiner%' then 'examine'
    when t.state like '%taxmapper_chief%' then 'approve taxmap'
    when t.state like '%taxmapper%' then 'taxmap'
    when t.state like '%appraiser%' then 'appraise'
    when t.state like '%appraiser_chief%' then 'approve appraisal'
    when t.state like '%recommender%' then 'recommend'
    when t.state like '%approver%' then 'approve'
    else t.state 
  end action, 
  1 as cnt 
from subdivision_task t 
inner join sys_user u on t.actor_objid = u.objid 
where t.state not like '%consolidation%'

union 


select 
  u.objid as userid, 
  u.name as username,
  t.enddate as txndate, 
  'cancelledfaas' as ref,
  case 
    when t.state like '%receiver%' then 'receive'
    when t.state like '%examiner%' then 'examine'
    when t.state like '%taxmapper_chief%' then 'approve taxmap'
    when t.state like '%taxmapper%' then 'taxmap'
    when t.state like '%appraiser%' then 'appraise'
    when t.state like '%appraiser_chief%' then 'approve appraisal'
    when t.state like '%recommender%' then 'recommend'
    when t.state like '%approver%' then 'approve'
    else t.state 
  end action, 
  1 as cnt 
from subdivision_task t 
inner join sys_user u on t.actor_objid = u.objid 
where t.state not like '%cancelledfaas%'
;



/*===================================================
* DELINQUENCY UPDATE 
====================================================*/


alter table report_rptdelinquency_barangay add idx int
;

update report_rptdelinquency_barangay set idx = 0 where idx is null
;


create view vw_faas_lookup
as 
SELECT 
f.*,
e.name as taxpayer_name, 
e.address_text as taxpayer_address,
pc.code AS classification_code, 
pc.code AS classcode, 
pc.name AS classification_name, 
pc.name AS classname, 
r.ry, r.rputype, r.totalmv, r.totalav,
r.totalareasqm, r.totalareaha, r.suffix, r.rpumasterid, 
rp.barangayid, rp.cadastrallotno, rp.blockno, rp.surveyno, rp.pintype, 
rp.section, rp.parcel, rp.stewardshipno, rp.pin, 
b.name AS barangay_name 
FROM faas f 
INNER JOIN faas_list fl on f.objid = fl.objid 
INNER JOIN rpu r ON f.rpuid = r.objid 
INNER JOIN realproperty rp ON f.realpropertyid = rp.objid 
INNER JOIN propertyclassification pc ON r.classification_objid = pc.objid 
INNER JOIN barangay b ON rp.barangayid = b.objid 
INNER JOIN entity e on f.taxpayer_objid = e.objid
;

drop  view if exists vw_rptpayment_item_detail
;

create view vw_rptpayment_item_detail
as 
select
  rpi.objid,
  rpi.parentid,
  rp.refid as rptledgerid, 
  rpi.rptledgerfaasid,
  rpi.year,
  rpi.qtr,
  rpi.revperiod, 
  case when rpi.revtype = 'basic' then rpi.amount else 0 end as basic,
  case when rpi.revtype = 'basic' then rpi.interest else 0 end as basicint,
  case when rpi.revtype = 'basic' then rpi.discount else 0 end as basicdisc,
  case when rpi.revtype = 'basic' then rpi.interest - rpi.discount else 0 end as basicdp,
  case when rpi.revtype = 'basic' then rpi.amount + rpi.interest - rpi.discount else 0 end as basicnet,
  case when rpi.revtype = 'basicidle' then rpi.amount + rpi.interest - rpi.discount else 0 end as basicidle,
  case when rpi.revtype = 'basicidle' then rpi.interest else 0 end as basicidleint,
  case when rpi.revtype = 'basicidle' then rpi.discount else 0 end as basicidledisc,
  case when rpi.revtype = 'basicidle' then rpi.interest - rpi.discount else 0 end as basicidledp,
  case when rpi.revtype = 'sef' then rpi.amount else 0 end as sef,
  case when rpi.revtype = 'sef' then rpi.interest else 0 end as sefint,
  case when rpi.revtype = 'sef' then rpi.discount else 0 end as sefdisc,
  case when rpi.revtype = 'sef' then rpi.interest - rpi.discount else 0 end as sefdp,
  case when rpi.revtype = 'sef' then rpi.amount + rpi.interest - rpi.discount else 0 end as sefnet,
  case when rpi.revtype = 'firecode' then rpi.amount + rpi.interest - rpi.discount else 0 end as firecode,
  case when rpi.revtype = 'sh' then rpi.amount + rpi.interest - rpi.discount else 0 end as sh,
  case when rpi.revtype = 'sh' then rpi.interest else 0 end as shint,
  case when rpi.revtype = 'sh' then rpi.discount else 0 end as shdisc,
  case when rpi.revtype = 'sh' then rpi.interest - rpi.discount else 0 end as shdp,
  rpi.amount + rpi.interest - rpi.discount as amount,
  rpi.partialled as partialled,
  rp.voided 
from rptpayment_item rpi
inner join rptpayment rp on rpi.parentid = rp.objid
;

drop view if exists vw_rptpayment_item 
;

create view vw_rptpayment_item 
as 
select 
    x.rptledgerid, 
    x.parentid,
    x.rptledgerfaasid,
    x.year,
    x.qtr,
    x.revperiod,
    sum(x.basic) as basic,
    sum(x.basicint) as basicint,
    sum(x.basicdisc) as basicdisc,
    sum(x.basicdp) as basicdp,
    sum(x.basicnet) as basicnet,
    sum(x.basicidle) as basicidle,
    sum(x.basicidleint) as basicidleint,
    sum(x.basicidledisc) as basicidledisc,
    sum(x.basicidledp) as basicidledp,
    sum(x.sef) as sef,
    sum(x.sefint) as sefint,
    sum(x.sefdisc) as sefdisc,
    sum(x.sefdp) as sefdp,
    sum(x.sefnet) as sefnet,
    sum(x.firecode) as firecode,
    sum(x.sh) as sh,
    sum(x.shint) as shint,
    sum(x.shdisc) as shdisc,
    sum(x.shdp) as shdp,
    sum(x.amount) as amount,
    max(x.partialled) as partialled,
    x.voided 
from vw_rptpayment_item_detail x
group by 
  x.rptledgerid, 
    x.parentid,
    x.rptledgerfaasid,
    x.year,
    x.qtr,
    x.revperiod,
    x.voided
;



alter table faas drop key ix_canceldate
;


alter table faas modify column canceldate date 
;

create index ix_faas_canceldate on faas(canceldate)
;




alter table machdetail modify column depreciation decimal(16,6)
;

/* 255-03001 */

-- create tables: resection and resection_item

drop table if exists resectionaffectedrpu;
drop table if exists resectionitem;
drop table if exists resection_item;
drop table if exists resection;

CREATE TABLE `resection` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `txnno` varchar(25) NOT NULL,
  `txndate` datetime NOT NULL,
  `lgu_objid` varchar(50) NOT NULL,
  `barangay_objid` varchar(50) NOT NULL,
  `pintype` varchar(3) NOT NULL,
  `section` varchar(3) NOT NULL,
  `originlgu_objid` varchar(50) NOT NULL,
  `memoranda` varchar(255) DEFAULT NULL,
  `taskid` varchar(50) DEFAULT NULL,
  `taskstate` varchar(50) DEFAULT NULL,
  `assignee_objid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `ux_resection_txnno` (`txnno`),
  KEY `FK_resection_lgu_org` (`lgu_objid`),
  KEY `FK_resection_barangay_org` (`barangay_objid`),
  KEY `FK_resection_originlgu_org` (`originlgu_objid`),
  KEY `ix_resection_state` (`state`),
  CONSTRAINT `FK_resection_barangay_org` FOREIGN KEY (`barangay_objid`) REFERENCES `sys_org` (`objid`),
  CONSTRAINT `FK_resection_lgu_org` FOREIGN KEY (`lgu_objid`) REFERENCES `sys_org` (`objid`),
  CONSTRAINT `FK_resection_originlgu_org` FOREIGN KEY (`originlgu_objid`) REFERENCES `sys_org` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `resection_item` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `faas_objid` varchar(50) NOT NULL,
  `faas_rputype` varchar(15) NOT NULL,
  `faas_pin` varchar(25) NOT NULL,
  `faas_suffix` int(255) NOT NULL,
  `newfaas_objid` varchar(50) DEFAULT NULL,
  `newfaas_rpuid` varchar(50) DEFAULT NULL,
  `newfaas_rpid` varchar(50) DEFAULT NULL,
  `newfaas_section` varchar(3) DEFAULT NULL,
  `newfaas_parcel` varchar(3) DEFAULT NULL,
  `newfaas_suffix` int(255) DEFAULT NULL,
  `newfaas_tdno` varchar(25) DEFAULT NULL,
  `newfaas_fullpin` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `ux_resection_item_tdno` (`newfaas_tdno`) USING BTREE,
  KEY `FK_resection_item_item` (`parent_objid`),
  KEY `FK_resection_item_faas` (`faas_objid`),
  KEY `FK_resection_item_newfaas` (`newfaas_objid`),
  KEY `ix_resection_item_fullpin` (`newfaas_fullpin`),
  CONSTRAINT `FK_resection_item_faas` FOREIGN KEY (`faas_objid`) REFERENCES `faas` (`objid`),
  CONSTRAINT `FK_resection_item_item` FOREIGN KEY (`parent_objid`) REFERENCES `resection` (`objid`),
  CONSTRAINT `FK_resection_item_newfaas` FOREIGN KEY (`newfaas_objid`) REFERENCES `faas` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `resection_task` (
  `objid` varchar(50) NOT NULL,
  `refid` varchar(50) DEFAULT NULL,
  `parentprocessid` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  `assignee_objid` varchar(50) DEFAULT NULL,
  `assignee_name` varchar(100) DEFAULT NULL,
  `assignee_title` varchar(80) DEFAULT NULL,
  `actor_objid` varchar(50) DEFAULT NULL,
  `actor_name` varchar(100) DEFAULT NULL,
  `actor_title` varchar(80) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `signature` longtext,
  PRIMARY KEY (`objid`),
  KEY `ix_assignee_objid` (`assignee_objid`),
  KEY `ix_refid` (`refid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
; 



delete from sys_wf_transition where processname ='resection';
delete from sys_wf_node where processname ='resection';

INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('appraiser', 'resection', 'Appraisal', 'state', '45', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('appraiser_chief', 'resection', 'Appraisal Approval', 'state', '55', NULL, 'RPT', 'APPRAISAL_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('approver', 'resection', 'Province Approval', 'state', '90', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-appraisal-chief', 'resection', 'For Appraisal Approval', 'state', '50', NULL, 'RPT', 'APPRAISAL_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-appraiser', 'resection', 'For Appraisal', 'state', '40', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-examiner', 'resection', 'For Examination', 'state', '10', NULL, 'RPT', 'EXAMINER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-recommender', 'resection', 'For Recommending Approval', 'state', '70', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-taxmapper', 'resection', 'For Taxmapping', 'state', '20', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('assign-taxmapping-approval', 'resection', 'For Taxmapping Approval', 'state', '30', NULL, 'RPT', 'TAXMAPPER_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('end', 'resection', 'End', 'end', '1000', NULL, 'RPT', NULL, NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('examiner', 'resection', 'Examination', 'state', '15', NULL, 'RPT', 'EXAMINER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('forapproval', 'resection', 'For Province Approval', 'state', '85', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('forprovapproval', 'resection', 'For Province Approval', 'state', '81', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('forprovsubmission', 'resection', 'For Province Submission', 'state', '80', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('provapprover', 'resection', 'Approved By Province', 'state', '96', NULL, 'RPT', 'APPROVER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('receiver', 'resection', 'Review and Verification', 'state', '5', NULL, 'RPT', 'RECEIVER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('recommender', 'resection', 'Recommending Approval', 'state', '75', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('start', 'resection', 'Start', 'start', '1', NULL, 'RPT', NULL, NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('taxmapper', 'resection', 'Taxmapping', 'state', '25', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('taxmapper_chief', 'resection', 'Taxmapping Approval', 'state', '35', NULL, 'RPT', 'TAXMAPPER_CHIEF', NULL, NULL, NULL);


INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('appraiser', 'resection', 'returnexaminer', 'examiner', '46', NULL, '[caption:\'Return to Examiner\', confirm:\'Return to examiner?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('appraiser', 'resection', 'returntaxmapper', 'taxmapper', '45', NULL, '[caption:\'Return to Taxmapper\', confirm:\'Return to taxmapper?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('appraiser', 'resection', 'submit', 'assign-recommender', '47', NULL, '[caption:\'Submit for Recommending Approval\', confirm:\'Submit?\', messagehandler:\'rptmessage:create\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('approver', 'resection', '', 'processing-approval', '90', NULL, '[caption:\'Manually Approve\', confirm:\'Approve?\', messagehandler:\'rptmessage:approval\']', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-appraiser', 'resection', '', 'appraiser', '40', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-examiner', 'resection', '', 'examiner', '10', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-recommender', 'resection', '', 'recommender', '70', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-taxmapper', 'resection', '', 'taxmapper', '20', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('examiner', 'resection', 'returnreceiver', 'receiver', '15', NULL, '[caption:\'Return to Receiver\', confirm:\'Return to receiver?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('examiner', 'resection', 'submit', 'assign-taxmapper', '16', NULL, '[caption:\'Submit for Taxmapping\', confirm:\'Submit?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('forprovsubmission', 'resection', 'completed', 'approver', '81', NULL, '[caption:\'Completed\', visible:false]', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('forprovsubmission', 'resection', 'returnapprover', 'recommender', '80', NULL, '[caption:\'Cancel Posting\', confirm:\'Cancel posting record?\']', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provapprover', 'resection', 'backforprovapproval', 'approver', '95', '#{data != null && data.state != \'APROVED\'}', '[caption:\'Cancel Posting\', confirm:\'Cancel posting record?\', visibleWhen=\"#{entity.state != \'APPROVED\'}\"]', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provapprover', 'resection', 'completed', 'end', '100', NULL, '[caption:\'Approved\', visible:false]', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('receiver', 'resection', 'delete', 'end', '6', NULL, '[caption:\'Delete\', confirm:\'Delete?\', closeonend:true]', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('receiver', 'resection', 'submit', 'assign-examiner', '5', NULL, '[caption:\'Submit For Examination\', confirm:\'Submit?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('recommender', 'resection', 'returnappraiser', 'appraiser', '77', NULL, '[caption:\'Return to Appraiser\', confirm:\'Return to appraiser?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('recommender', 'resection', 'returnexaminer', 'examiner', '75', NULL, '[caption:\'Return to Examiner\', confirm:\'Return to examiner?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('recommender', 'resection', 'returntaxmapper', 'taxmapper', '76', NULL, '[caption:\'Return to Taxmapper\', confirm:\'Return to taxmapper?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('recommender', 'resection', 'submit', 'forprovsubmission', '78', NULL, '[caption:\'Submit to Province\', confirm:\'Submit to Province?\', messagehandler:\'rptmessage:create\']', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('start', 'resection', '', 'receiver', '1', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('taxmapper', 'resection', 'returnexaminer', 'examiner', '26', NULL, '[caption:\'Return to Examiner\', confirm:\'Return to examiner?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('taxmapper', 'resection', 'returnreceiver', 'receiver', '25', NULL, '[caption:\'Return to Receiver\', confirm:\'Return to receiver?\', messagehandler:\'default\']', '', NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('taxmapper', 'resection', 'submit', 'assign-appraiser', '26', NULL, '[caption:\'Submit for Appraisal\', confirm:\'Submit?\', messagehandler:\'rptmessage:create\']', NULL, NULL, NULL);


/* 255-03001 */
alter table rptcertification add properties text;

	
alter table faas_signatory 
    add reviewer_objid varchar(50),
    add reviewer_name varchar(100),
    add reviewer_title varchar(75),
    add reviewer_dtsigned datetime,
    add reviewer_taskid varchar(50),
    add assessor_name varchar(100),
    add assessor_title varchar(100);

alter table cancelledfaas_signatory 
    add reviewer_objid varchar(50),
    add reviewer_name varchar(100),
    add reviewer_title varchar(75),
    add reviewer_dtsigned datetime,
    add reviewer_taskid varchar(50),
    add assessor_name varchar(100),
    add assessor_title varchar(100);



    
drop table if exists rptacknowledgement_item
;
drop table if exists rptacknowledgement
;


CREATE TABLE `rptacknowledgement` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `txnno` varchar(25) NOT NULL,
  `txndate` datetime DEFAULT NULL,
  `taxpayer_objid` varchar(50) DEFAULT NULL,
  `txntype_objid` varchar(50) DEFAULT NULL,
  `releasedate` datetime DEFAULT NULL,
  `releasemode` varchar(50) DEFAULT NULL,
  `receivedby` varchar(255) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `pin` varchar(25) DEFAULT NULL,
  `createdby_objid` varchar(25) DEFAULT NULL,
  `createdby_name` varchar(25) DEFAULT NULL,
  `createdby_title` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `ux_rptacknowledgement_txnno` (`txnno`),
  KEY `ix_rptacknowledgement_pin` (`pin`),
  KEY `ix_rptacknowledgement_taxpayerid` (`taxpayer_objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `rptacknowledgement_item` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `trackingno` varchar(25) NULL,
  `faas_objid` varchar(50) DEFAULT NULL,
  `newfaas_objid` varchar(50) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table rptacknowledgement_item 
  add constraint fk_rptacknowledgement_item_rptacknowledgement
  foreign key (parent_objid) references rptacknowledgement(objid)
;

create index ix_rptacknowledgement_parentid on rptacknowledgement_item(parent_objid)
;

create unique index ux_rptacknowledgement_itemno on rptacknowledgement_item(trackingno)
;

create index ix_rptacknowledgement_item_faasid  on rptacknowledgement_item(faas_objid)
;

create index ix_rptacknowledgement_item_newfaasid on rptacknowledgement_item(newfaas_objid)
;

drop view if exists vw_faas_lookup 
;


CREATE view vw_faas_lookup AS 
select 
  fl.objid AS objid,
  fl.state AS state,
  fl.rpuid AS rpuid,
  fl.utdno AS utdno,
  fl.tdno AS tdno,
  fl.txntype_objid AS txntype_objid,
  fl.effectivityyear AS effectivityyear,
  fl.effectivityqtr AS effectivityqtr,
  fl.taxpayer_objid AS taxpayer_objid,
  fl.owner_name AS owner_name,
  fl.owner_address AS owner_address,
  fl.prevtdno AS prevtdno,
  fl.cancelreason AS cancelreason,
  fl.cancelledbytdnos AS cancelledbytdnos,
  fl.lguid AS lguid,
  fl.realpropertyid AS realpropertyid,
  fl.displaypin AS fullpin,
  fl.originlguid AS originlguid,
  e.name AS taxpayer_name,
  e.address_text AS taxpayer_address,
  pc.code AS classification_code,
  pc.code AS classcode,
  pc.name AS classification_name,
  pc.name AS classname,
  fl.ry AS ry,
  fl.rputype AS rputype,
  fl.totalmv AS totalmv,
  fl.totalav AS totalav,
  fl.totalareasqm AS totalareasqm,
  fl.totalareaha AS totalareaha,
  fl.barangayid AS barangayid,
  fl.cadastrallotno AS cadastrallotno,
  fl.blockno AS blockno,
  fl.surveyno AS surveyno,
  fl.pin AS pin,
  fl.barangay AS barangay_name,
  fl.trackingno
from faas_list fl
left join propertyclassification pc on fl.classification_objid = pc.objid
left join entity e on fl.taxpayer_objid = e.objid
;


alter table faas modify column prevtdno varchar(800);
alter table faas_list  
  modify column prevtdno varchar(800),
  modify column owner_name varchar(5000),
  modify column cadastrallotno varchar(900);


create index ix_faaslist_txntype_objid on faas_list(txntype_objid);



alter table rptledger modify column prevtdno varchar(800);
create index ix_rptledger_prevtdno on rptledger(prevtdno);
create index ix_rptledgerfaas_tdno on rptledgerfaas(tdno);

  
alter table rptledger modify column owner_name varchar(1500) not null;
create index ix_rptledger_owner_name on rptledger(owner_name);
  

  /* SUBLEDGER : add beneficiary info */

alter table rptledger add beneficiary_objid varchar(50);
create index ix_beneficiary_objid on rptledger(beneficiary_objid);


/* COMPROMISE UPDATE */
alter table rptcompromise_item add qtr int;


/* 255-03012 */

/*=====================================
* LEDGER TAG
=====================================*/
CREATE TABLE `rptledger_tag` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `tag` varchar(255) NOT NULL,
  PRIMARY KEY (`objid`),
  KEY `FK_rptledgertag_rptledger` (`parent_objid`),
  UNIQUE KEY `ux_rptledger_tag` (`parent_objid`,`tag`),
  CONSTRAINT `FK_rptledgertag_rptledger` FOREIGN KEY (`parent_objid`) REFERENCES `rptledger` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;





/* 255-03013 */
alter table resection_item add newfaas_claimno varchar(25);
alter table resection_item add faas_claimno varchar(25);

/* 255-03015 */

CREATE TABLE `rptcertification_online` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `reftype` varchar(25) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `refdate` date NOT NULL,
  `orno` varchar(25) DEFAULT NULL,
  `ordate` date DEFAULT NULL,
  `oramount` decimal(16,2) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_state` (`state`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_orno` (`orno`),
  CONSTRAINT `fk_rptcertification_online_rptcertification` FOREIGN KEY (`objid`) REFERENCES `rptcertification` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `assessmentnotice_online` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `reftype` varchar(25) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `refdate` date NOT NULL,
  `orno` varchar(25) DEFAULT NULL,
  `ordate` date DEFAULT NULL,
  `oramount` decimal(16,2) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_state` (`state`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_orno` (`orno`),
  CONSTRAINT `fk_assessmentnotice_online_assessmentnotice` FOREIGN KEY (`objid`) REFERENCES `assessmentnotice` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;



/*===============================================================
**
** FAAS ANNOTATION
**
===============================================================*/
CREATE TABLE `faasannotation_faas` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `faas_objid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


alter table faasannotation_faas 
add constraint fk_faasannotationfaas_faasannotation foreign key(parent_objid)
references faasannotation (objid)
;

alter table faasannotation_faas 
add constraint fk_faasannotationfaas_faas foreign key(faas_objid)
references faas (objid)
;

create index ix_parent_objid on faasannotation_faas(parent_objid)
;

create index ix_faas_objid on faasannotation_faas(faas_objid)
;


create unique index ux_parent_faas on faasannotation_faas(parent_objid, faas_objid)
;

alter table faasannotation modify column faasid varchar(50) null
;



-- insert annotated faas
insert into faasannotation_faas(
  objid, 
  parent_objid,
  faas_objid 
)
select 
  objid, 
  objid as parent_objid,
  faasid as faas_objid 
from faasannotation
;



/*============================================
*
*  LEDGER FAAS FACTS
*
=============================================*/
INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) 
VALUES ('rptledger_rule_include_ledger_faases', '0', 'Include Ledger FAASes as rule facts', 'checkbox', 'LANDTAX')
;

INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) 
VALUES ('rptledger_post_ledgerfaas_by_actualuse', '0', 'Post by Ledger FAAS by actual use', 'checkbox', 'LANDTAX')
;


/* 255-03016 */

/*================================================================
*
* RPTLEDGER REDFLAG
*
================================================================*/

CREATE TABLE `rptledger_redflag` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `caseno` varchar(25) NULL,
  `dtfiled` datetime NULL,
  `type` varchar(25) NOT NULL,
  `finding` text,
  `remarks` text,
  `blockaction` varchar(25) DEFAULT NULL,
  `filedby_objid` varchar(50) DEFAULT NULL,
  `filedby_name` varchar(255) DEFAULT NULL,
  `filedby_title` varchar(50) DEFAULT NULL,
  `resolvedby_objid` varchar(50) DEFAULT NULL,
  `resolvedby_name` varchar(255) DEFAULT NULL,
  `resolvedby_title` varchar(50) DEFAULT NULL,
  `dtresolved` datetime NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create index ix_parent_objid on rptledger_redflag(parent_objid)
;
create index ix_state on rptledger_redflag(state)
;
create unique index ux_caseno on rptledger_redflag(caseno)
;
create index ix_type on rptledger_redflag(type)
;
create index ix_filedby_objid on rptledger_redflag(filedby_objid)
;
create index ix_resolvedby_objid on rptledger_redflag(resolvedby_objid)
;

alter table rptledger_redflag 
add constraint fk_rptledger_redflag_rptledger foreign key (parent_objid)
references rptledger(objid)
;

alter table rptledger_redflag 
add constraint fk_rptledger_redflag_filedby foreign key (filedby_objid)
references sys_user(objid)
;

alter table rptledger_redflag 
add constraint fk_rptledger_redflag_resolvedby foreign key (resolvedby_objid)
references sys_user(objid)
;





/*==================================================
* RETURNED TASK 
==================================================*/
alter table faas_task add returnedby varchar(100)
;
alter table subdivision_task add returnedby varchar(100)
;
alter table consolidation_task add returnedby varchar(100)
;
alter table cancelledfaas_task add returnedby varchar(100)
;
alter table resection_task add returnedby varchar(100)
;


/* 255-03017 */

/*================================================================
*
* LANDTAX SHARE POSTING
*
================================================================*/

alter table rptpayment_share 
  add iscommon int,
  add `year` int
;

update rptpayment_share set iscommon = 0 where iscommon is null 
;


-- CREATE TABLE `cashreceipt_rpt_share_forposting` (
--   `objid` varchar(50) NOT NULL,
--   `receiptid` varchar(50) NOT NULL,
--   `rptledgerid` varchar(50) NOT NULL,
--   `txndate` datetime NOT NULL,
--   `error` int(255) NOT NULL,
--   `msg` text,
--   PRIMARY KEY (`objid`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8
-- ;
-- 
-- 
-- create UNIQUE index `ux_receiptid_rptledgerid` on cashreceipt_rpt_share_forposting (`receiptid`,`rptledgerid`)
-- ;
-- create index `fk_cashreceipt_rpt_share_forposing_rptledger` on cashreceipt_rpt_share_forposting (`rptledgerid`)
-- ;
-- create index `fk_cashreceipt_rpt_share_forposing_cashreceipt` on cashreceipt_rpt_share_forposting (`receiptid`)
-- ;
-- 
-- alter table cashreceipt_rpt_share_forposting add CONSTRAINT `fk_cashreceipt_rpt_share_forposing_rptledger` 
-- FOREIGN KEY (`rptledgerid`) REFERENCES `rptledger` (`objid`)
-- ;
-- alter table cashreceipt_rpt_share_forposting add CONSTRAINT `fk_cashreceipt_rpt_share_forposing_cashreceipt` 
-- FOREIGN KEY (`receiptid`) REFERENCES `cashreceipt` (`objid`)
-- ;




/*==================================================
**
** BLDG DATE CONSTRUCTED SUPPORT 
**
===================================================*/

alter table bldgrpu add dtconstructed date;

DELETE FROM sys_wf_transition WHERE processname = 'batchgr';
DELETE FROM sys_wf_node WHERE processname = 'batchgr';

INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('start', 'batchgr', 'Start', 'start', '1', NULL, 'RPT', NULL, NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-receiver', 'batchgr', 'For Review and Verification', 'state', '2', NULL, 'RPT', 'RECEIVER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('receiver', 'batchgr', 'Review and Verification', 'state', '5', NULL, 'RPT', 'RECEIVER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-examiner', 'batchgr', 'For Examination', 'state', '10', NULL, 'RPT', 'EXAMINER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('examiner', 'batchgr', 'Examination', 'state', '15', NULL, 'RPT', 'EXAMINER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-taxmapper', 'batchgr', 'For Taxmapping', 'state', '20', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-provtaxmapper', 'batchgr', 'For Taxmapping', 'state', '20', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('taxmapper', 'batchgr', 'Taxmapping', 'state', '25', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('provtaxmapper', 'batchgr', 'Taxmapping', 'state', '25', NULL, 'RPT', 'TAXMAPPER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-taxmapping-approval', 'batchgr', 'For Taxmapping Approval', 'state', '30', NULL, 'RPT', 'TAXMAPPER_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('taxmapper_chief', 'batchgr', 'Taxmapping Approval', 'state', '35', NULL, 'RPT', 'TAXMAPPER_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-appraiser', 'batchgr', 'For Appraisal', 'state', '40', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-provappraiser', 'batchgr', 'For Appraisal', 'state', '40', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('appraiser', 'batchgr', 'Appraisal', 'state', '45', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('provappraiser', 'batchgr', 'Appraisal', 'state', '45', NULL, 'RPT', 'APPRAISER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-appraisal-chief', 'batchgr', 'For Appraisal Approval', 'state', '50', NULL, 'RPT', 'APPRAISAL_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('appraiser_chief', 'batchgr', 'Appraisal Approval', 'state', '55', NULL, 'RPT', 'APPRAISAL_CHIEF', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-recommender', 'batchgr', 'For Recommending Approval', 'state', '70', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('recommender', 'batchgr', 'Recommending Approval', 'state', '75', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('forprovsubmission', 'batchgr', 'For Province Submission', 'state', '80', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('forprovapproval', 'batchgr', 'For Province Approval', 'state', '81', NULL, 'RPT', 'RECOMMENDER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('forapproval', 'batchgr', 'Provincial Assessor Approval', 'state', '85', NULL, 'RPT', 'APPROVER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('assign-approver', 'batchgr', 'For Provincial Assessor Approval', 'state', '90', NULL, 'RPT', 'APPROVER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('approver', 'batchgr', 'Provincial Assessor Approval', 'state', '95', NULL, 'RPT', 'APPROVER,ASSESSOR', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('provapprover', 'batchgr', 'Approved By Province', 'state', '96', NULL, 'RPT', 'APPROVER', NULL, NULL, NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `properties`, `ui`, `tracktime`) VALUES ('end', 'batchgr', 'End', 'end', '1000', NULL, 'RPT', NULL, NULL, NULL, NULL);

INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('start', 'batchgr', '', 'assign-receiver', '1', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-receiver', 'batchgr', '', 'receiver', '2', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('receiver', 'batchgr', 'submit', 'assign-provtaxmapper', '5', NULL, '[caption:\'Submit For Taxmapping\', confirm:\'Submit?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-examiner', 'batchgr', '', 'examiner', '10', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('examiner', 'batchgr', 'returnreceiver', 'receiver', '15', NULL, '[caption:\'Return to Receiver\', confirm:\'Return to receiver?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('examiner', 'batchgr', 'submit', 'assign-provtaxmapper', '16', NULL, '[caption:\'Submit for Approval\', confirm:\'Submit?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-provtaxmapper', 'batchgr', '', 'provtaxmapper', '20', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provtaxmapper', 'batchgr', 'returnexaminer', 'examiner', '25', NULL, '[caption:\'Return to Examiner\', confirm:\'Return to examiner?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provtaxmapper', 'batchgr', 'submit', 'assign-provappraiser', '26', NULL, '[caption:\'Submit for Approval\', confirm:\'Submit?\', messagehandler:\'rptmessage:sign\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-provappraiser', 'batchgr', '', 'provappraiser', '40', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provappraiser', 'batchgr', 'returntaxmapper', 'provtaxmapper', '45', NULL, '[caption:\'Return to Taxmapper\', confirm:\'Return to taxmapper?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provappraiser', 'batchgr', 'returnexaminer', 'examiner', '46', NULL, '[caption:\'Return to Examiner\', confirm:\'Return to examiner?\', messagehandler:\'default\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provappraiser', 'batchgr', 'submit', 'assign-approver', '47', NULL, '[caption:\'Submit for Approval\', confirm:\'Submit?\', messagehandler:\'rptmessage:sign\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('assign-approver', 'batchgr', '', 'approver', '70', NULL, '[caption:\'Assign To Me\', confirm:\'Assign task to you?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('approver', 'batchgr', 'approve', 'provapprover', '90', NULL, '[caption:\'Approve\', confirm:\'Approve record?\', messagehandler:\'rptmessage:sign\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provapprover', 'batchgr', 'backforprovapproval', 'approver', '95', NULL, '[caption:\'Cancel Posting\', confirm:\'Cancel posting record?\']', NULL, NULL, NULL);
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('provapprover', 'batchgr', 'completed', 'end', '100', NULL, '[caption:\'Approved\', visible:false]', NULL, NULL, NULL);


/* 255-03018 */

/*==================================================
**
** ONLINE BATCH GR 
**
===================================================*/
drop table if exists zz_tmp_batchgr_item 
;
drop table if exists zz_tmp_batchgr
;

create table zz_tmp_batchgr 
select * from batchgr
;

create table zz_tmp_batchgr_item 
select * from batchgr_item
;

drop table if exists batchgr_task
;

alter table batchgr 
  add txntype_objid varchar(50),
  add txnno varchar(25),
  add txndate datetime,
  add effectivityyear int,
  add effectivityqtr int,
  add originlgu_objid varchar(50)
;


create index ix_ry on batchgr(ry)
;
create index ix_txnno on batchgr(txnno)
;
create index ix_classificationid on batchgr(classification_objid)
;
create index ix_section on batchgr(section)
;

alter table batchgr 
add constraint fk_batchgr_lguid foreign key(lgu_objid) 
references sys_org(objid)
;

alter table batchgr 
add constraint fk_batchgr_barangayid foreign key(barangay_objid) 
references sys_org(objid)
;

alter table batchgr 
add constraint fk_batchgr_classificationid foreign key(classification_objid) 
references propertyclassification(objid)
;


alter table batchgr_item add subsuffix int
;

alter table batchgr_item 
add constraint fk_batchgr_item_faas foreign key(objid) 
references faas(objid)
;

create table `batchgr_task` (
  `objid` varchar(50) not null,
  `refid` varchar(50) default null,
  `parentprocessid` varchar(50) default null,
  `state` varchar(50) default null,
  `startdate` datetime default null,
  `enddate` datetime default null,
  `assignee_objid` varchar(50) default null,
  `assignee_name` varchar(100) default null,
  `assignee_title` varchar(80) default null,
  `actor_objid` varchar(50) default null,
  `actor_name` varchar(100) default null,
  `actor_title` varchar(80) default null,
  `message` varchar(255) default null,
  `signature` longtext,
  `returnedby` varchar(100) default null,
  primary key (`objid`),
  key `ix_assignee_objid` (`assignee_objid`),
  key `ix_refid` (`refid`)
) engine=innodb default charset=utf8;

alter table batchgr_task 
add constraint fk_batchgr_task_batchgr foreign key(refid) 
references batchgr(objid)
;




drop view if exists vw_batchgr
;

create view vw_batchgr 
as 
select 
  bg.*,
  l.name as lgu_name,
  b.name as barangay_name,
  pc.name as classification_name,
  t.objid AS taskid,
  t.state AS taskstate,
  t.assignee_objid 
from batchgr bg
inner join sys_org l on bg.lgu_objid = l.objid 
left join sys_org b on bg.barangay_objid = b.objid
left join propertyclassification pc on bg.classification_objid = pc.objid 
left join batchgr_task t on bg.objid = t.refid  and t.enddate is null 
;


/* insert task */
insert into batchgr_task (
  objid,
  refid,
  parentprocessid,
  state,
  startdate,
  enddate,
  assignee_objid,
  assignee_name,
  assignee_title,
  actor_objid,
  actor_name,
  actor_title,
  message,
  signature,
  returnedby
)
select 
  concat(b.objid, '-appraiser') as objid,
  b.objid as refid,
  null as parentprocessid,
  'appraiser' as state,
  b.appraiser_dtsigned as startdate,
  b.appraiser_dtsigned as enddate,
  null as assignee_objid,
  b.appraiser_name as assignee_name,
  null as assignee_title,
  null as actor_objid,
  b.appraiser_name as actor_name,
  null as actor_title,
  null as message,
  null as signature,
  null as returnedby
from batchgr b
where b.appraiser_name is not null
;


insert into batchgr_task (
  objid,
  refid,
  parentprocessid,
  state,
  startdate,
  enddate,
  assignee_objid,
  assignee_name,
  assignee_title,
  actor_objid,
  actor_name,
  actor_title,
  message,
  signature,
  returnedby
)
select 
  concat(b.objid, '-taxmapper') as objid,
  b.objid as refid,
  null as parentprocessid,
  'taxmapper' as state,
  b.taxmapper_dtsigned as startdate,
  b.taxmapper_dtsigned as enddate,
  null as assignee_objid,
  b.taxmapper_name as assignee_name,
  null as assignee_title,
  null as actor_objid,
  b.taxmapper_name as actor_name,
  null as actor_title,
  null as message,
  null as signature,
  null as returnedby
from batchgr b
where b.taxmapper_name is not null
;


insert into batchgr_task (
  objid,
  refid,
  parentprocessid,
  state,
  startdate,
  enddate,
  assignee_objid,
  assignee_name,
  assignee_title,
  actor_objid,
  actor_name,
  actor_title,
  message,
  signature,
  returnedby
)
select 
  concat(b.objid, '-recommender') as objid,
  b.objid as refid,
  null as parentprocessid,
  'recommender' as state,
  b.recommender_dtsigned as startdate,
  b.recommender_dtsigned as enddate,
  null as assignee_objid,
  b.recommender_name as assignee_name,
  null as assignee_title,
  null as actor_objid,
  b.recommender_name as actor_name,
  null as actor_title,
  null as message,
  null as signature,
  null as returnedby
from batchgr b
where b.recommender_name is not null
;



insert into batchgr_task (
  objid,
  refid,
  parentprocessid,
  state,
  startdate,
  enddate,
  assignee_objid,
  assignee_name,
  assignee_title,
  actor_objid,
  actor_name,
  actor_title,
  message,
  signature,
  returnedby
)
select 
  concat(b.objid, '-approver') as objid,
  b.objid as refid,
  null as parentprocessid,
  'approver' as state,
  b.approver_dtsigned as startdate,
  b.approver_dtsigned as enddate,
  null as assignee_objid,
  b.approver_name as assignee_name,
  null as assignee_title,
  null as actor_objid,
  b.approver_name as actor_name,
  null as actor_title,
  null as message,
  null as signature,
  null as returnedby
from batchgr b
where b.approver_name is not null
;


alter table batchgr 
  drop column appraiser_name,
  drop column appraiser_dtsigned,
  drop column taxmapper_name,
  drop column taxmapper_dtsigned,
  drop column recommender_name,
  drop column recommender_dtsigned,
  drop column approver_name,
  drop column approver_dtsigned
;  




/*===========================================
*
*  ENTITY MAPPING (PROVINCE)
*
============================================*/

DROP TABLE IF EXISTS `entity_mapping`
;

CREATE TABLE `entity_mapping` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `org_objid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


drop view if exists vw_entity_mapping
;

create view vw_entity_mapping
as 
select 
  r.*,
  e.entityno,
  e.name, 
  e.address_text as address_text,
  a.province as address_province,
  a.municipality as address_municipality
from entity_mapping r 
inner join entity e on r.objid = e.objid 
left join entity_address a on e.address_objid = a.objid
left join sys_org b on a.barangay_objid = b.objid 
left join sys_org m on b.parent_objid = m.objid 
;




/*===========================================
*
*  CERTIFICATION UPDATES
*
============================================*/
drop view if exists vw_rptcertification_item
;

create view vw_rptcertification_item
as 
SELECT 
  rci.rptcertificationid,
  f.objid as faasid,
  f.fullpin, 
  f.tdno,
  e.objid as taxpayerid,
  e.name as taxpayer_name, 
  f.owner_name, 
  f.administrator_name,
  f.titleno,  
  f.rpuid, 
  pc.code AS classcode, 
  pc.name AS classname,
  so.name AS lguname,
  b.name AS barangay, 
  r.rputype, 
  r.suffix,
  r.totalareaha AS totalareaha,
  r.totalareasqm AS totalareasqm,
  r.totalav,
  r.totalmv, 
  rp.street,
  rp.blockno,
  rp.cadastrallotno,
  rp.surveyno,
  r.taxable,
  f.effectivityyear,
  f.effectivityqtr
FROM rptcertificationitem rci 
  INNER JOIN faas f ON rci.refid = f.objid 
  INNER JOIN rpu r ON f.rpuid = r.objid 
  INNER JOIN propertyclassification pc ON r.classification_objid = pc.objid 
  INNER JOIN realproperty rp ON f.realpropertyid = rp.objid 
  INNER JOIN barangay b ON rp.barangayid = b.objid 
  INNER JOIN sys_org so on f.lguid = so.objid 
  INNER JOIN entity e on f.taxpayer_objid = e.objid 
;



/*===========================================
*
*  SUBDIVISION ASSISTANCE
*
============================================*/
drop table if exists subdivision_assist_item
; 

drop table if exists subdivision_assist
; 

CREATE TABLE `subdivision_assist` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `taskstate` varchar(50) NOT NULL,
  `assignee_objid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table subdivision_assist 
add constraint fk_subdivision_assist_subdivision foreign key(parent_objid)
references subdivision(objid)
;

alter table subdivision_assist 
add constraint fk_subdivision_assist_user foreign key(assignee_objid)
references sys_user(objid)
;

create index ix_parent_objid on subdivision_assist(parent_objid)
;

create index ix_assignee_objid on subdivision_assist(assignee_objid)
;

create unique index ux_parent_assignee on subdivision_assist(parent_objid, taskstate, assignee_objid)
;


CREATE TABLE `subdivision_assist_item` (
`objid` varchar(50) NOT NULL,
  `subdivision_objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `pintype` varchar(10) NOT NULL,
  `section` varchar(5) NOT NULL,
  `startparcel` int(255) NOT NULL,
  `endparcel` int(255) NOT NULL,
  `parcelcount` int(11) DEFAULT NULL,
  `parcelcreated` int(11) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table subdivision_assist_item 
add constraint fk_subdivision_assist_item_subdivision foreign key(subdivision_objid)
references subdivision(objid)
;

alter table subdivision_assist_item 
add constraint fk_subdivision_assist_item_subdivision_assist foreign key(parent_objid)
references subdivision_assist(objid)
;

create index ix_subdivision_objid on subdivision_assist_item(subdivision_objid)
;

create index ix_parent_objid on subdivision_assist_item(parent_objid)
;



/*==================================================
**
** REALTY TAX CREDIT
**
===================================================*/

drop table if exists rpttaxcredit
;



CREATE TABLE `rpttaxcredit` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `type` varchar(25) NOT NULL,
  `txnno` varchar(25) DEFAULT NULL,
  `txndate` datetime DEFAULT NULL,
  `reftype` varchar(25) DEFAULT NULL,
  `refid` varchar(50) DEFAULT NULL,
  `refno` varchar(25) NOT NULL,
  `refdate` date NOT NULL,
  `amount` decimal(16,2) NOT NULL,
  `amtapplied` decimal(16,2) NOT NULL,
  `rptledger_objid` varchar(50) NOT NULL,
  `srcledger_objid` varchar(50) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `approvedby_objid` varchar(50) DEFAULT NULL,
  `approvedby_name` varchar(150) DEFAULT NULL,
  `approvedby_title` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


create index ix_state on rpttaxcredit(state)
;

create index ix_type on rpttaxcredit(type)
;

create unique index ux_txnno on rpttaxcredit(txnno)
;

create index ix_reftype on rpttaxcredit(reftype)
;

create index ix_refid on rpttaxcredit(refid)
;

create index ix_refno on rpttaxcredit(refno)
;

create index ix_rptledger_objid on rpttaxcredit(rptledger_objid)
;

create index ix_srcledger_objid on rpttaxcredit(srcledger_objid)
;

alter table rpttaxcredit
add constraint fk_rpttaxcredit_rptledger foreign key (rptledger_objid)
references rptledger (objid)
;

alter table rpttaxcredit
add constraint fk_rpttaxcredit_srcledger foreign key (srcledger_objid)
references rptledger (objid)
;

alter table rpttaxcredit
add constraint fk_rpttaxcredit_sys_user foreign key (approvedby_objid)
references sys_user(objid)
;





/*==================================================
**
** MACHINE SMV
**
===================================================*/

CREATE TABLE `machine_smv` (
  `objid` varchar(50) NOT NULL,
  `parent_objid` varchar(50) NOT NULL,
  `machine_objid` varchar(50) NOT NULL,
  `expr` varchar(255) NOT NULL,
  `previd` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create index ix_parent_objid on machine_smv(parent_objid)
;
create index ix_machine_objid on machine_smv(machine_objid)
;
create index ix_previd on machine_smv(previd)
;
create unique index ux_parent_machine on machine_smv(parent_objid, machine_objid)
;



alter table machine_smv
add constraint fk_machinesmv_machrysetting foreign key (parent_objid)
references machrysetting (objid)
;

alter table machine_smv
add constraint fk_machinesmv_machine foreign key (machine_objid)
references machine(objid)
;


alter table machine_smv
add constraint fk_machinesmv_machinesmv foreign key (previd)
references machine_smv(objid)
;


create view vw_machine_smv 
as 
select 
  ms.*, 
  m.code,
  m.name
from machine_smv ms 
inner join machine m on ms.machine_objid = m.objid 
;

alter table machdetail 
  add smvid varchar(50),
  add params text
;

update machdetail set params = '[]' where params is null
;

create index ix_smvid on machdetail(smvid)
;


alter table machdetail 
add constraint fk_machdetail_machine_smv foreign key(smvid)
references machine_smv(objid)
;




/*==================================================
**
** AFFECTED FAS TXNTYPE (DP)
**
===================================================*/

INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) 
VALUES ('faas_affected_rpu_txntype_dp', '0', 'Set affected improvements FAAS txntype to DP e.g. SD and CS', 'checkbox', 'ASSESSOR')
;


alter table bldgrpu add occpermitno varchar(25)
;

alter table rpu add isonline int
;

update rpu set isonline = 0 where isonline is null 
;



drop table if exists sync_data_forprocess
;
drop table if exists sync_data_pending
;
drop table if exists sync_data
;

CREATE TABLE `syncdata_forsync` (
  `objid` varchar(50) NOT NULL,
  `reftype` varchar(100) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `action` varchar(100) NOT NULL,
  `orgid` varchar(25) NOT NULL,
  `dtfiled` datetime NOT NULL,
  `createdby_objid` varchar(50) DEFAULT NULL,
  `createdby_name` varchar(255) DEFAULT NULL,
  `createdby_title` varchar(100) DEFAULT NULL,
  `info` text,
  PRIMARY KEY (`objid`),
  KEY `ix_dtfiled` (`dtfiled`),
  KEY `ix_createdbyid` (`createdby_objid`),
  KEY `ix_reftype` (`reftype`) USING BTREE,
  KEY `ix_refno` (`refno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `syncdata` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(50) NOT NULL,
  `refno` varchar(50) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `dtfiled` datetime NOT NULL,
  `orgid` varchar(50) DEFAULT NULL,
  `remote_orgid` varchar(50) DEFAULT NULL,
  `remote_orgcode` varchar(20) DEFAULT NULL,
  `remote_orgclass` varchar(20) DEFAULT NULL,
  `sender_objid` varchar(50) DEFAULT NULL,
  `sender_name` varchar(150) DEFAULT NULL,
  `fileid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_reftype` (`reftype`),
  KEY `ix_refno` (`refno`),
  KEY `ix_orgid` (`orgid`),
  KEY `ix_dtfiled` (`dtfiled`),
  KEY `ix_fileid` (`fileid`),
  KEY `ix_refid` (`refid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `syncdata_item` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(255) NOT NULL,
  `refno` varchar(50) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `error` text,
  `idx` int(255) NOT NULL,
  `info` text,
  PRIMARY KEY (`objid`),
  KEY `ix_parentid` (`parentid`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  CONSTRAINT `fk_syncdataitem_syncdata` FOREIGN KEY (`parentid`) REFERENCES `syncdata` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;



CREATE TABLE `syncdata_forprocess` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_parentid` (`parentid`),
  CONSTRAINT `fk_syncdata_forprocess_syncdata_item` FOREIGN KEY (`objid`) REFERENCES `syncdata_item` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


CREATE TABLE `syncdata_pending` (
  `objid` varchar(50) NOT NULL,
  `error` text,
  `expirydate` datetime DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_expirydate` (`expirydate`),
  CONSTRAINT `fk_syncdata_pending_syncdata` FOREIGN KEY (`objid`) REFERENCES `syncdata` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;




/* PREVTAXABILITY */
alter table faas_previous add prevtaxability varchar(10)
;


update faas_previous pf, faas f, rpu r set 
  pf.prevtaxability = case when r.taxable = 1 then 'TAXABLE' else 'EXEMPT' end 
where pf.prevfaasid = f.objid
and f.rpuid = r.objid 
and pf.prevtaxability is null 
;


/* 255-03020 */

alter table syncdata_item add async int default 0
;
alter table syncdata_item add dependedaction varchar(100)
;

create index ix_state on syncdata(state)
;
create index ix_state on syncdata_item(state)
;

create table syncdata_offline_org (
  orgid varchar(50) not null,
  expirydate datetime not null,
  primary key(orgid)
)
;




/*=======================================
*
*  QRRPA: Mixed-Use Support
*
=======================================*/

drop view if exists vw_rpu_assessment
;

create view vw_rpu_assessment as 
select 
  r.objid,
  r.rputype,
  dpc.objid as dominantclass_objid,
  dpc.code as dominantclass_code,
  dpc.name as dominantclass_name,
  dpc.orderno as dominantclass_orderno,
  ra.areasqm,
  ra.areaha,
  ra.marketvalue,
  ra.assesslevel,
  ra.assessedvalue,
  ra.taxable,
  au.code as actualuse_code, 
  au.name  as actualuse_name,
  auc.objid as actualuse_objid,
  auc.code as actualuse_classcode,
  auc.name as actualuse_classname,
  auc.orderno as actualuse_orderno
from rpu r 
inner join propertyclassification dpc on r.classification_objid = dpc.objid
inner join rpu_assessment ra on r.objid = ra.rpuid
inner join landassesslevel au on ra.actualuse_objid = au.objid 
left join propertyclassification auc on au.classification_objid = auc.objid

union 

select 
  r.objid,
  r.rputype,
  dpc.objid as dominantclass_objid,
  dpc.code as dominantclass_code,
  dpc.name as dominantclass_name,
  dpc.orderno as dominantclass_orderno,
  ra.areasqm,
  ra.areaha,
  ra.marketvalue,
  ra.assesslevel,
  ra.assessedvalue,
  ra.taxable,
  au.code as actualuse_code, 
  au.name  as actualuse_name,
  auc.objid as actualuse_objid,
  auc.code as actualuse_classcode,
  auc.name as actualuse_classname,
  auc.orderno as actualuse_orderno
from rpu r 
inner join propertyclassification dpc on r.classification_objid = dpc.objid
inner join rpu_assessment ra on r.objid = ra.rpuid
inner join bldgassesslevel au on ra.actualuse_objid = au.objid 
left join propertyclassification auc on au.classification_objid = auc.objid

union 

select 
  r.objid,
  r.rputype,
  dpc.objid as dominantclass_objid,
  dpc.code as dominantclass_code,
  dpc.name as dominantclass_name,
  dpc.orderno as dominantclass_orderno,
  ra.areasqm,
  ra.areaha,
  ra.marketvalue,
  ra.assesslevel,
  ra.assessedvalue,
  ra.taxable,
  au.code as actualuse_code, 
  au.name  as actualuse_name,
  auc.objid as actualuse_objid,
  auc.code as actualuse_classcode,
  auc.name as actualuse_classname,
  auc.orderno as actualuse_orderno
from rpu r 
inner join propertyclassification dpc on r.classification_objid = dpc.objid
inner join rpu_assessment ra on r.objid = ra.rpuid
inner join machassesslevel au on ra.actualuse_objid = au.objid 
left join propertyclassification auc on au.classification_objid = auc.objid

union 

select 
  r.objid,
  r.rputype,
  dpc.objid as dominantclass_objid,
  dpc.code as dominantclass_code,
  dpc.name as dominantclass_name,
  dpc.orderno as dominantclass_orderno,
  ra.areasqm,
  ra.areaha,
  ra.marketvalue,
  ra.assesslevel,
  ra.assessedvalue,
  ra.taxable,
  au.code as actualuse_code, 
  au.name  as actualuse_name,
  auc.objid as actualuse_objid,
  auc.code as actualuse_classcode,
  auc.name as actualuse_classname,
  auc.orderno as actualuse_orderno
from rpu r 
inner join propertyclassification dpc on r.classification_objid = dpc.objid
inner join rpu_assessment ra on r.objid = ra.rpuid
inner join planttreeassesslevel au on ra.actualuse_objid = au.objid 
left join propertyclassification auc on au.classification_objid = auc.objid

union 

select 
  r.objid,
  r.rputype,
  dpc.objid as dominantclass_objid,
  dpc.code as dominantclass_code,
  dpc.name as dominantclass_name,
  dpc.orderno as dominantclass_orderno,
  ra.areasqm,
  ra.areaha,
  ra.marketvalue,
  ra.assesslevel,
  ra.assessedvalue,
  ra.taxable,
  au.code as actualuse_code, 
  au.name  as actualuse_name,
  auc.objid as actualuse_objid,
  auc.code as actualuse_classcode,
  auc.name as actualuse_classname,
  auc.orderno as actualuse_orderno
from rpu r 
inner join propertyclassification dpc on r.classification_objid = dpc.objid
inner join rpu_assessment ra on r.objid = ra.rpuid
inner join miscassesslevel au on ra.actualuse_objid = au.objid 
left join propertyclassification auc on au.classification_objid = auc.objid
;



drop table if exists syncdata_offline_org
;

DROP TABLE if exists `syncdata_org` 
; 


CREATE TABLE `syncdata_org` (
  `orgid` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `errorcount` int default 0,
  PRIMARY KEY (`orgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

create index ix_state on syncdata_org(state)
;

insert into syncdata_org (
  orgid, 
  state, 
  errorcount
)
select 
  objid,
  'ACTIVE',
  0
from sys_org
where orgclass = 'municipality'
;


drop table if exists syncdata_forprocess
;

CREATE TABLE `syncdata_forprocess` (
  `objid` varchar(50) NOT NULL,
  `processed` int(11) DEFAULT '0',
  PRIMARY KEY (`objid`),
  CONSTRAINT `fk_forprocess_syncdata_item` FOREIGN KEY (`objid`) REFERENCES `syncdata_item` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


DROP TABLE if exists `batch_rpttaxcredit_ledger_posted`
;

DROP TABLE if exists `batch_rpttaxcredit_ledger`
;

DROP TABLE if exists `batch_rpttaxcredit`
;

CREATE TABLE `batch_rpttaxcredit` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `txndate` date NOT NULL,
  `txnno` varchar(25) NOT NULL,
  `rate` decimal(10,2) NOT NULL,
  `paymentfrom` date DEFAULT NULL,
  `paymentto` varchar(255) DEFAULT NULL,
  `creditedyear` int(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `validity` date NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_state` (`state`),
  KEY `ix_txnno` (`txnno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `batch_rpttaxcredit_ledger` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `error` varchar(255) NULL,
  barangayid varchar(50) not null, 
  PRIMARY KEY (`objid`),
  KEY `ix_parentid` (`parentid`),
  KEY `ix_state` (`state`),
KEY `ix_barangayid` (`barangayid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table batch_rpttaxcredit_ledger 
add constraint fk_rpttaxcredit_rptledger_parent foreign key(parentid) references batch_rpttaxcredit(objid)
;

alter table batch_rpttaxcredit_ledger 
add constraint fk_rpttaxcredit_rptledger_rptledger foreign key(objid) references rptledger(objid)
;




CREATE TABLE `batch_rpttaxcredit_ledger_posted` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `barangayid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_parentid` (`parentid`),
  KEY `ix_barangayid` (`barangayid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table batch_rpttaxcredit_ledger_posted 
add constraint fk_rpttaxcredit_rptledger_posted_parent foreign key(parentid) references batch_rpttaxcredit(objid)
;

alter table batch_rpttaxcredit_ledger_posted 
add constraint fk_rpttaxcredit_rptledger_posted_rptledger foreign key(objid) references rptledger(objid)
;

create view vw_batch_rpttaxcredit_error
as 
select br.*, rl.tdno
from batch_rpttaxcredit_ledger br 
inner join rptledger rl on br.objid = rl.objid 
where br.state = 'ERROR'
;

alter table rpttaxcredit add info text
;


alter table rpttaxcredit add discapplied decimal(16,2) not null
;

update rpttaxcredit set discapplied = 0 where discapplied is null 
;



CREATE TABLE `rpt_syncdata_forsync` (
  `objid` varchar(50) NOT NULL,
  `reftype` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `orgid` varchar(50) NOT NULL,
  `dtfiled` datetime NOT NULL,
  `createdby_objid` varchar(50) DEFAULT NULL,
  `createdby_name` varchar(255) DEFAULT NULL,
  `createdby_title` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_orgid` (`orgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `rpt_syncdata` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `dtfiled` datetime NOT NULL,
  `orgid` varchar(50) NOT NULL,
  `remote_orgid` varchar(50) DEFAULT NULL,
  `remote_orgcode` varchar(5) DEFAULT NULL,
  `remote_orgclass` varchar(25) DEFAULT NULL,
  `sender_objid` varchar(50) DEFAULT NULL,
  `sender_name` varchar(255) DEFAULT NULL,
  `sender_title` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_state` (`state`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_orgid` (`orgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `rpt_syncdata_item` (
  `objid` varchar(50) NOT NULL,
  `parentid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `idx` int(11) NOT NULL,
  `info` text,
  PRIMARY KEY (`objid`),
  KEY `ix_parentid` (`parentid`),
  KEY `ix_state` (`state`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  CONSTRAINT `FK_parentid_rpt_syncdata` FOREIGN KEY (`parentid`) REFERENCES `rpt_syncdata` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `rpt_syncdata_error` (
  `objid` varchar(50) NOT NULL,
  `filekey` varchar(1000) NOT NULL,
  `error` text,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(50) NOT NULL,
  `refno` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `idx` int(11) NOT NULL,
  `info` text,
  `parent` text,
  `remote_orgid` varchar(50) DEFAULT NULL,
  `remote_orgcode` varchar(5) DEFAULT NULL,
  `remote_orgclass` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_refid` (`refid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_filekey` (`filekey`(255)),
  KEY `ix_remote_orgid` (`remote_orgid`),
  KEY `ix_remote_orgcode` (`remote_orgcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) 
VALUES ('assesser_new_sync_lgus', NULL, 'List of LGUs using new sync facility', NULL, 'ASSESSOR')
;



ALTER TABLE rpt_syncdata_forsync ADD remote_orgid VARCHAR(15)
;


INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) VALUES ('fileserver_upload_task_active', '0', 'Activate / Deactivate upload task', 'boolean', 'SYSTEM')
;






INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) 
VALUES ('fileserver_download_task_active', '1', 'Activate / Deactivate download task', 'boolean', 'SYSTEM')
;


CREATE TABLE `rpt_syncdata_completed` (
  `objid` varchar(255) NOT NULL,
  `idx` int(255) DEFAULT NULL,
  `action` varchar(100) DEFAULT NULL,
  `refno` varchar(50) DEFAULT NULL,
  `refid` varchar(50) DEFAULT NULL,
  `reftype` varchar(50) DEFAULT NULL,
  `parent_orgid` varchar(50) DEFAULT NULL,
  `sender_name` varchar(255) DEFAULT NULL,
  `sender_title` varchar(255) DEFAULT NULL,
  `dtcreated` datetime DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_refno` (`refno`),
  KEY `ix_refid` (`refid`),
  KEY `ix_parent_orgid` (`parent_orgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


alter table rptledger_item add (
  fromqtr int null, 
  toqtr int null 
)
; 














/** RULESETS AND RULES **/

alter table sys_rule_fact_field modify column objid varchar(100) 
;

alter table sys_rule_condition_constraint  modify column field_objid varchar(255) 
;

alter table sys_rule_actiondef_param  modify column objid varchar(100) 
;

alter table sys_rule_action_param  modify column actiondefparam_objid varchar(100) 
;




delete from sys_rule_action_param where parentid in ( 
  select ra.objid 
  from sys_rule r, sys_rule_action ra 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and ra.parentid=r.objid 
)
;

delete from sys_rule_actiondef_param where parentid in ( 
  select ra.objid from sys_ruleset_actiondef rsa 
    inner join sys_rule_actiondef ra on ra.objid=rsa.actiondef 
  where rsa.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
);

delete from sys_rule_actiondef where objid in ( 
  select actiondef from sys_ruleset_actiondef where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
);

delete from sys_rule_action where parentid in ( 
  select objid from sys_rule 
  where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
)
;

delete from sys_rule_condition_constraint where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and rc.parentid=r.objid 
)
;

delete from sys_rule_condition_var where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and rc.parentid=r.objid 
)
;

delete from sys_rule_condition where parentid in ( 
  select objid from sys_rule where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
)
;


delete from sys_rule_fact_field where parentid in (
	select objid from sys_rule_fact where domain in ('rpt', 'landtax')
)
;

delete  from sys_rule_fact where domain in ('rpt', 'landtax')
;

delete from sys_rule_deployed where objid in ( 
  select objid from sys_rule where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
    
)
;

delete from sys_rule where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_ruleset_fact where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;


delete from sys_ruleset_actiondef where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_rulegroup where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_ruleset where domain in ('rpt', 'landtax')
;



set foreign_key_checks = 0
;

delete from sys_rule_action_param where parentid in ( 
  select ra.objid 
  from sys_rule r, sys_rule_action ra 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and ra.parentid=r.objid 
)
;

delete from sys_rule_actiondef_param where parentid in ( 
  select ra.objid from sys_ruleset_actiondef rsa 
    inner join sys_rule_actiondef ra on ra.objid=rsa.actiondef 
  where rsa.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
);

delete from sys_rule_actiondef where objid in ( 
  select actiondef from sys_ruleset_actiondef where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
);

delete from sys_rule_action where parentid in ( 
  select objid from sys_rule 
  where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
)
;

delete from sys_rule_condition_constraint where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and rc.parentid=r.objid 
)
;

delete from sys_rule_condition_var where parentid in ( 
  select rc.objid 
  from sys_rule r, sys_rule_condition rc 
  where r.ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    ) and rc.parentid=r.objid 
)
;

delete from sys_rule_condition where parentid in ( 
  select objid from sys_rule where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
)
;


delete from sys_rule_fact_field where parentid in (
  select objid from sys_rule_fact where domain in ('rpt', 'landtax')
)
;

delete  from sys_rule_fact where domain in ('rpt', 'landtax')
;

delete from sys_rule_deployed where objid in ( 
  select objid from sys_rule where ruleset in (
        select name  from sys_ruleset where domain in ('rpt', 'landtax')
    )
    
)
;

delete from sys_rule where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_ruleset_fact where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;


delete from sys_ruleset_actiondef where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_rulegroup where ruleset in (
    select name  from sys_ruleset where domain in ('rpt', 'landtax')
)
;

delete from sys_ruleset where domain in ('rpt', 'landtax')
;



REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('bldgassessment', 'Building Assessment Rules', 'bldgassessment', 'RPT', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('landassessment', 'Land Assessment Rules', 'landassessment', 'RPT', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('machassessment', 'Machinery Assessment Rules', 'machassessment', 'RPT', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('miscassessment', 'Miscellaneous Assessment Rules', 'miscassessment', 'RPT', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('planttreeassessment', 'Plant/Tree Assessment Rules', 'planttreeassessment', 'RPT', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('rptbilling', 'RPT Billing Rules', 'rptbilling', 'LANDTAX', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('rptledger', 'Ledger Billing Rules', 'rptledger', 'LANDTAX', 'RULE_AUTHOR', NULL);
REPLACE INTO `sys_ruleset` (`name`, `title`, `packagename`, `domain`, `role`, `permission`) VALUES ('rptrequirement', 'RPT Requirement Rules', 'rptrequirement', 'RPT', 'RULE_AUTHOR', NULL);

REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ADDITIONAL', 'bldgassessment', 'Additional Item Computation', '18');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ADJUSTMENT', 'bldgassessment', 'Adjustment Computation', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ADJUSTMENT', 'landassessment', 'Adjustment Computation', '14');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ADJUSTMENT', 'planttreeassessment', 'Adjustment Computation', '15');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFER-DEPRECIATION', 'miscassessment', 'After Depreciation Computation', '16');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ADDITIONAL', 'bldgassessment', 'After Additional Item Computation', '19');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ADJUSTMENT', 'bldgassessment', 'After Adjustment Computation', '30');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ADJUSTMENT', 'landassessment', 'After Adjustment Computation', '15');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ADJUSTMENT', 'planttreeassessment', 'AFter Adjustment Computation', '16');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSEDVALUE', 'landassessment', 'After Assessed Value Computation', '45');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSEDVALUE', 'machassessment', 'After Machine Assessed Value Computation', '45');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSEDVALUE', 'miscassessment', 'After Assessed Value Computation', '45');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSEDVALUE', 'planttreeassessment', 'After Assessed Value Computation', '45');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSLEVEL', 'bldgassessment', 'After Calculate Assess Level', '60');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSLEVEL', 'landassessment', 'After Assess Level Computation', '36');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSLEVEL', 'machassessment', 'After Machine Assess Level Computation', '36');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSLEVEL', 'miscassessment', 'After Assess Level Computation', '36');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSLEVEL', 'planttreeassessment', 'After Assess Level Computation', '36');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-ASSESSVALUE', 'bldgassessment', 'After Assess Value Computation', '75');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-BASEMARKETVALUE', 'bldgassessment', 'After Base Market Value Computation', '15');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-BASEMARKETVALUE', 'landassessment', 'After Base Market Value Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-BASEMARKETVALUE', 'machassessment', 'After Machine Base Market Value Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-BASEMARKETVALUE', 'miscassessment', 'After Base Market Value Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-BASEMARKETVALUE', 'planttreeassessment', 'After Base Market Value Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-DEPRECIATION', 'bldgassessment', 'After Depreciation Computation', '34');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-DEPRECIATION', 'machassessment', 'After Machine Depreciation Computation', '12');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-FLOOR', 'bldgassessment', 'AFter Floor Computation', '3');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-MARKETVALUE', 'bldgassessment', 'After Market Value Computation', '45');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-MARKETVALUE', 'landassessment', 'After Market Value Computation', '30');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-MARKETVALUE', 'machassessment', 'After Machine Market Value Computation', '30');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-MARKETVALUE', 'miscassessment', 'After Market Value Computation', '30');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-MARKETVALUE', 'planttreeassessment', 'After Market Value Computation', '30');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-SUMMARY', 'bldgassessment', 'After Summary Computation', '105');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-SUMMARY', 'landassessment', 'After Summary Computation', '105');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-SUMMARY', 'machassessment', 'After Summary Computation', '105');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-SUMMARY', 'miscassessment', 'After Summary Computation', '105');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER-SUMMARY', 'planttreeassessment', 'After Summary Computation', '105');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_DISCOUNT', 'rptbilling', 'After Discount Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_PENALTY', 'rptbilling', 'After Penalty Computation', '8');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_REQUIREMENT', 'rptrequirement', 'After Requirement', '2');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_SUMMARY', 'rptbilling', 'After Summary', '21');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('AFTER_TAX', 'rptledger', 'Post Tax Computation', '3');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSEDVALUE', 'landassessment', 'Assessed Value Computation', '40');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSEDVALUE', 'machassessment', 'Machine Assessed Value Computation', '40');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSEDVALUE', 'miscassessment', 'Assessed Value Computation', '40');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSEDVALUE', 'planttreeassessment', 'Assessed Value Computation', '40');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSLEVEL', 'bldgassessment', 'Calculate Assess Level', '55');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSLEVEL', 'landassessment', 'Assess Level Computation', '35');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSLEVEL', 'machassessment', 'Machine Assess Level Computation', '35');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSLEVEL', 'miscassessment', 'Assess Level Computation', '35');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSLEVEL', 'planttreeassessment', 'Assess Level Computation', '35');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('ASSESSVALUE', 'bldgassessment', 'Assess Value Computation', '70');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BASEMARKETVALUE', 'bldgassessment', 'Base Market Value Computation', '10');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BASEMARKETVALUE', 'landassessment', 'Base Market Value Computation', '5');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BASEMARKETVALUE', 'machassessment', 'Machine Base Market Value Computation', '5');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BASEMARKETVALUE', 'miscassessment', 'Base Market Value Computation', '5');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BASEMARKETVALUE', 'planttreeassessment', 'Base Market Value Computation', '5');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ADDITIONAL', 'bldgassessment', 'Before Additional Item Computation', '17');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ADJUSTMENT', 'bldgassessment', 'Before Adjustment Computation', '20');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ADJUSTMENT', 'landassessment', 'Before Adjustment Computation', '13');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ASSESSLEVEL', 'bldgassessment', 'Before Calculate Assess Level', '50');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ASSESSLEVEL', 'miscassessment', 'Before Assess Level Computation', '34');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-ASSESSVALUE', 'bldgassessment', 'Before Assess Value Computation', '65');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-BASEMARKETVALUE', 'bldgassessment', 'Before Base Market Value Computation', '5');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-DEPRECIATON', 'bldgassessment', 'Before Depreciation Computation', '32');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-MARKETVALUE', 'bldgassessment', 'Before Market Value Computation', '35');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE-MARKETVALUE', 'landassessment', 'Before Market Value', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BEFORE_SUMMARY', 'rptbilling', 'Before Summary ', '19');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('BRGY_SHARE', 'rptbilling', 'Barangay Share Computation', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('DEPRECIATION', 'bldgassessment', 'Depreciation Computation', '33');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('DEPRECIATION', 'machassessment', 'Machine Depreciation Computation', '11');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('DEPRECIATION', 'miscassessment', 'Depreciation Computation', '15');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('DISCOUNT', 'rptbilling', 'Discount Computation', '9');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('FLOOR', 'bldgassessment', 'Floor Computation', '2');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INIT', 'rptbilling', 'Init', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INIT', 'rptledger', 'Init', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INITIAL', 'landassessment', 'Initial Computation', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INITIAL', 'machassessment', 'Initial Computation', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INITIAL', 'miscassessment', 'Initial Computation', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('INITIAL', 'planttreeassessment', 'Initial Computation', '0');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('LEDGER_ITEM', 'rptledger', 'Ledger Item Posting', '1');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('LGU_SHARE', 'rptbilling', 'LGU Share Computation', '26');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MARKETVALUE', 'bldgassessment', 'Market Value Computation', '40');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MARKETVALUE', 'landassessment', 'Market Value Computation', '26');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MARKETVALUE', 'machassessment', 'Machine Market Value Computation', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MARKETVALUE', 'miscassessment', 'Market Value Computation', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MARKETVALUE', 'planttreeassessment', 'Market Value Computation', '25');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MUASSESSEDVALUE', 'machassessment', 'Actual Use Assessed Value Computation', '55');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('MUASSESSLEVEL', 'machassessment', 'Actual Use Assess Level Computation', '50');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('PENALTY', 'rptbilling', 'Penalty Computation', '7');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('PRE-ASSESSMENT', 'bldgassessment', 'Pre-Assessment', '1');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('PROV_SHARE', 'rptbilling', 'Province Share Computation', '27');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('REQUIREMENT', 'rptrequirement', 'Requirement', '1');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'bldgassessment', 'Summary', '100');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'landassessment', 'Summary Computation', '100');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'machassessment', 'Summary Computation', '100');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'miscassessment', 'Summary Computation', '100');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'planttreeassessment', 'Summary Computation', '100');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('SUMMARY', 'rptbilling', 'Summary', '20');
REPLACE INTO `sys_rulegroup` (`name`, `ruleset`, `title`, `sortorder`) VALUES ('TAX', 'rptledger', 'Tax Computation', '2');

REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-128a4cad:146f96a678e:-7efa');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-21ad68c1:146fc2282bb:-7b6e');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-3151');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-4365');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-4807');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-5573');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-619b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-723b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-79a8');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-7a02');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-2486b0ca:146fff66c3e:-7ce5');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-39192c48:1471ebc2797:-7dae');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-39192c48:1471ebc2797:-7dee');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-3e8edbea:156bc08656a:-6112');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-3e8edbea:156bc08656a:-6112');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF-3e8edbea:156bc08656a:-6112');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF-3e8edbea:156bc08656a:-6112');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF-3e8edbea:156bc08656a:-6112');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-46fca07e:14c545f3e6a:-65ca');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-585c89e6:16156f39eeb:-77aa');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-585c89e6:16156f39eeb:-7dcb');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF-59249a93:1614f57bd58:-7db8');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-5e76cf73:14d69e9c549:-71e7');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-5e76cf73:14d69e9c549:-7232');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-5e76cf73:14d69e9c549:-72c3');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF-5e76cf73:14d69e9c549:-7e09');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF-5ed6c5b0:16145892be0:-6988');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF-5ed6c5b0:16145892be0:-7d18');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF-60c99d04:1470b276e7f:-7c52');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-66032c9:16155c11111:-7c6a');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-78fba29f:161df51b937:-7089');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-78fba29f:161df51b937:-7568');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF-7c494b7d:161d65781c4:-7cb4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF-7c494b7d:161d65781c4:-7d6a');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF-7deff7e5:161b60a3048:-7212');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF1441128c:1471efa4c1c:-69a5');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF1b4af871:14e3cc46e09:-344d');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF1b4af871:14e3cc46e09:-344d');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF1b4af871:14e3cc46e09:-344d');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF1b4af871:14e3cc46e09:-344d');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF1b4af871:14e3cc46e09:-344d');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF1b4af871:14e3cc46e09:-3543');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF1b4af871:14e3cc46e09:-358c');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF1b4af871:14e3cc46e09:-35cc');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF1b4af871:14e3cc46e09:-3612');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF1be07afa:1452a9809e9:-6958');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF1e772168:14c5a447e35:-6703');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF1e772168:14c5a447e35:-7e28');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF1e772168:14c5a447e35:-7eaf');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF1e772168:14c5a447e35:-7ed1');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF1fcd83ed:149bc7d0f75:-7d4b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF23f2d934:14719fd6b68:-725b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF36885e11:150188b0d78:-7e0c');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF3afe51b9:146f7088d9c:-7c7b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF3e2b89cb:146ff734573:-7c47');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF5022d8ba:1589ae965a4:-7b0e');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF57c48737:1472331021e:-7f84');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF59614e16:14c5e56ecc8:-7ef4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF59614e16:14c5e56ecc8:-7f1c');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF59614e16:14c5e56ecc8:-7f42');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF59614e16:14c5e56ecc8:-7f6b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF5b4ac915:147baaa06b4:-7dbe');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF5b84d618:1615428187f:-6904');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF5d750d7e:161889cc785:-7d47');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptbilling', 'RULADEF634d9a3c:161503ff1dc:-707a');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptledger', 'RULADEF634d9a3c:161503ff1dc:-787a');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF6b62feef:14c53ac1f59:-7e2c');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF6b62feef:14c53ac1f59:-7e59');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF6b62feef:14c53ac1f59:-7e83');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF6b62feef:14c53ac1f59:-7ea2');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('rptrequirement', 'RULADEF6d66cc31:1446cc9522e:-7d56');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('bldgassessment', 'RULADEF7efff901:15104440241:-7de4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('landassessment', 'RULADEF7efff901:15104440241:-7de4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF7efff901:15104440241:-7de4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('miscassessment', 'RULADEF7efff901:15104440241:-7de4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('planttreeassessment', 'RULADEF7efff901:15104440241:-7de4');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF7efff901:15104440241:5e0b');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF7efff901:15104fb0702:3868');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF7efff901:15104fb0702:4487');
REPLACE INTO `sys_ruleset_actiondef` (`ruleset`, `actiondef`) VALUES ('machassessment', 'RULADEF7efff901:15104fb0702:4545');

REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT-16b3898d:15d15d43bd3:-55bb');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptrequirement', 'RULFACT-245f3fbb:14f9b505a11:-7f93');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-2486b0ca:146fff66c3e:-57b0');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-2486b0ca:146fff66c3e:-711c');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-2486b0ca:146fff66c3e:-7ad1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-2486b0ca:146fff66c3e:-7b6a');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-2486b0ca:146fff66c3e:-7e0e');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-39192c48:1471ebc2797:-7faf');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT-39192c48:1471ebc2797:-7faf');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('machassessment', 'RULFACT-39192c48:1471ebc2797:-7faf');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('miscassessment', 'RULFACT-39192c48:1471ebc2797:-7faf');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('planttreeassessment', 'RULFACT-39192c48:1471ebc2797:-7faf');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT-5e76cf73:14d69e9c549:-7f07');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptledger', 'RULFACT-5ed6c5b0:16145892be0:-7d9c');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT-66032c9:16155c11111:-7deb');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptledger', 'RULFACT-6d782e97:161e4c91fda:-3f40');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT-78fba29f:161df51b937:-77bb');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT-79a9a347:15cfcae84de:-3956');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT1b4af871:14e3cc46e09:-34c1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT1b4af871:14e3cc46e09:-34c1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('machassessment', 'RULFACT1b4af871:14e3cc46e09:-34c1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('miscassessment', 'RULFACT1b4af871:14e3cc46e09:-34c1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('planttreeassessment', 'RULFACT1b4af871:14e3cc46e09:-34c1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('miscassessment', 'RULFACT1b4af871:14e3cc46e09:-36aa');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT1be07afa:1452a9809e9:-731e');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('machassessment', 'RULFACT1e772168:14c5a447e35:-7f78');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('machassessment', 'RULFACT1e772168:14c5a447e35:-7fd5');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT357018a9:1452a5dcbf7:-793b');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT3afe51b9:146f7088d9c:-7db1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT3afe51b9:146f7088d9c:-7eb6');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT3afe51b9:146f7088d9c:-7eb6');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('machassessment', 'RULFACT3afe51b9:146f7088d9c:-7eb6');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('miscassessment', 'RULFACT3afe51b9:146f7088d9c:-7eb6');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('planttreeassessment', 'RULFACT3afe51b9:146f7088d9c:-7eb6');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT3e2b89cb:146ff734573:-7fcb');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT49ae4bad:141e3b6758c:-7ba3');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT547c5381:1451ae1cd9c:-7933');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptledger', 'RULFACT547c5381:1451ae1cd9c:-7933');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptbilling', 'RULFACT547c5381:1451ae1cd9c:-798f');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('miscassessment', 'RULFACT59614e16:14c5e56ecc8:-7fd1');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('bldgassessment', 'RULFACT5b4ac915:147baaa06b4:-7146');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('landassessment', 'RULFACT5b4ac915:147baaa06b4:-7146');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('planttreeassessment', 'RULFACT6b62feef:14c53ac1f59:-7f69');
REPLACE INTO `sys_ruleset_fact` (`ruleset`, `rulefact`) VALUES ('rptrequirement', 'RULFACT6d66cc31:1446cc9522e:-7ee1');

REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-2486b0ca:146fff66c3e:-2c4a', 'DEPLOYED', 'CALC_ACTUAL_USE_MV', 'bldgassessment', 'MARKETVALUE', 'CALC ACTUAL USE MV', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '2759238484b59d31f56261116605faab');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-2486b0ca:146fff66c3e:-38e4', 'DEPLOYED', 'CALC_FLOOR_MARKET_VALUE', 'bldgassessment', 'BEFORE-MARKETVALUE', 'CALC FLOOR MARKET VALUE', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'd822fe856bf48f3bfd2926ab4e294ee7');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-2486b0ca:146fff66c3e:-4192', 'DEPLOYED', 'CALC_DEPRECIATION', 'bldgassessment', 'DEPRECIATION', 'CALC DEPRECIATION', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '2eabacdedf33063a6c8b20017d34b97b');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-2486b0ca:146fff66c3e:-4697', 'DEPLOYED', 'CALC_DEPRECATION_RATE_FROM_SKED', 'bldgassessment', 'BEFORE-DEPRECIATON', 'CALC DEPRECATION RATE FROM SKED', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'e06b1f57da76f1d2ca627d22e83b5167');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-2486b0ca:146fff66c3e:-6b05', 'DEPLOYED', 'CALC_FLOOR_BMV', 'bldgassessment', 'FLOOR', 'CALC FLOOR BMV', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '56bac316c5d30efaacc8171441372d12');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'DEPLOYED', 'COMPUTE_AV_NOT_ROUND', 'landassessment', 'ASSESSEDVALUE', 'COMPUTE AV', NULL, '50000', NULL, NULL, '2017-06-29 19:58:53', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '63f241a4786b0c2b6f2c88709acaab7f');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-3e8edbea:156bc08656a:-5f05', 'DEPLOYED', 'RECALC_RPU_TOTAL_AV', 'landassessment', 'AFTER-SUMMARY', 'RECALC RPU TOTAL AV', NULL, '40000', NULL, NULL, '2016-08-24 04:03:36', 'USR-ADMIN', 'ADMIN', '1', '28a5f97338a417d17ccaee9e644a11e9');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-46fca07e:14c545f3e6a:-33b4', 'DEPLOYED', 'ROUND_FLOOR_BMV_TO_NEAREST_ONES', 'bldgassessment', 'AFTER-BASEMARKETVALUE', 'ROUND_FLOOR BMV TO NEAREST ONES', NULL, '50000', NULL, NULL, '2015-04-06 20:40:36', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'f0b9271d125caf8e07737adcd733536e');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-46fca07e:14c545f3e6a:-350f', 'DEPLOYED', 'ROUND_ACTUALUSE_BMV_TO_NEAREST_ONE', 'bldgassessment', 'AFTER-BASEMARKETVALUE', 'ROUND ACTUALUSE BMV TO NEAREST ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:36', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '51e57bceee6445f3dce3840ddfb61544');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-46fca07e:14c545f3e6a:-7740', 'DEPLOYED', 'CALC_MV', 'landassessment', 'MARKETVALUE', 'CALC MV', NULL, '50000', NULL, NULL, '2015-04-06 20:40:42', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '07e29d90464a4fc34aa0ffe96d964673');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-46fca07e:14c545f3e6a:-7a8b', 'DEPLOYED', 'CALC_BMV', 'landassessment', 'BASEMARKETVALUE', 'CALC BMV', NULL, '50000', NULL, NULL, '2015-04-06 20:40:42', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '1db19c702e94d1c33fc7e1a71d3b565b');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-585c89e6:16156f39eeb:-770f', 'DEPLOYED', 'AGGREGATE_PREVIOUS_ITEMS', 'rptbilling', 'BEFORE_SUMMARY', 'AGGREGATE PREVIOUS ITEMS', NULL, '50000', NULL, NULL, '2018-02-02 07:43:11', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'c818a9c02a016e6b528c5d17a0feebeb');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-59249a93:1614f57bd58:-7d49', 'DEPLOYED', 'BASIC_AND_SEF', 'rptledger', 'LEDGER_ITEM', 'BASIC AND SEF', NULL, '50000', NULL, NULL, '2018-01-31 19:14:59', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '8ec701f4ce5d86f1fd446e53b78b2049');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-5e76cf73:14d69e9c549:-7084', 'DEPLOYED', 'ROUND_LAND_ITEM_ADJUSTMENTS', 'landassessment', 'AFTER-ADJUSTMENT', 'ROUND LAND ITEM ADJUSTMENTS', NULL, '50000', NULL, NULL, '2015-05-18 19:33:40', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '1892984f333b4aabcc2906d4678d2cc9');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-5e76cf73:14d69e9c549:-7fd4', 'DEPLOYED', 'ROUND_ADJ_TO_ONE', 'landassessment', 'AFTER-ADJUSTMENT', 'ROUND ADJ TO ONE', NULL, '50000', NULL, NULL, '2015-05-18 19:04:33', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '78e4869170fbbb40293042e54c5570c6');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-60c99d04:1470b276e7f:-7ecc', 'DEPLOYED', 'CALC_BMV', 'bldgassessment', 'BASEMARKETVALUE', 'CALC BMV ', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '023c91e15f241739c011d917011a7486');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-621d5f20:16222e9bf6d:-19d5', 'DEPLOYED', 'PENALTY_BASIC_SEF_LESS_CY', 'rptbilling', 'PENALTY', 'PENALTY_BASIC_SEF_LESS CY', NULL, '50000', NULL, NULL, '2018-03-14 18:00:01', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', 'ee36932ba167deb5a28c00b2e9764812');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-621d5f20:16222e9bf6d:-bc0', 'DEPLOYED', 'DISCOUNT_CURRENT_QTRLY', 'rptbilling', 'DISCOUNT', 'DISCOUNT CURRENT QTRLY', NULL, '50000', NULL, NULL, '2018-03-14 18:04:31', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', '534d62984d4abf6e0385f9115660b15e');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-6c4ec747:154bd626092:-5616', 'DEPLOYED', 'CALC_BMV_BY_SWORN_STATEMENT', 'machassessment', 'BASEMARKETVALUE', 'CALC BMV BY SWORN STATEMENT', NULL, '50000', NULL, NULL, '2016-05-16 23:56:01', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'c30a1b9b0021c30ac2d4ce5e9be40bcf');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-762e9176:15d067a9c42:-5aa0', 'DEPLOYED', 'RECALC_RPU_TOTAL_AV', 'miscassessment', 'AFTER-SUMMARY', 'RECALC_RPU_TOTAL_AV', NULL, '60000', NULL, NULL, '2017-07-02 20:29:56', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'f27645c4c31dcf2922e22406585d03d3');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-762e9176:15d067a9c42:-5e26', 'DEPLOYED', 'CALC_TOTAL_ASSESSEMENT_AV', 'miscassessment', 'AFTER-SUMMARY', 'CALC_TOTAL_ASSESSEMENT_AV', NULL, '50000', NULL, NULL, '2017-07-02 20:28:17', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'b83072447047ca6f1e3a4513a0ad9d33');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-4837', 'DEPLOYED', 'BRGY_SHARE_ADVANCE', 'rptbilling', 'BRGY_SHARE', 'BRGY SHARE ADVANCE', NULL, '50000', NULL, NULL, '2018-02-28 23:46:45', 'USR-ADMIN', 'ADMIN', '1', '7862a1e473270050079701625b699c7a');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-4951', 'DEPLOYED', 'BRGY_SHARE_CURRENT_PENALTY', 'rptbilling', 'BRGY_SHARE', 'BRGY SHARE CURRENT PENALTY', NULL, '50000', NULL, NULL, '2018-02-28 23:45:31', 'USR-ADMIN', 'ADMIN', '1', '93245e2d9ffde59b4914d011d9e69161');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-4a59', 'DEPLOYED', 'BRGY_SHARE_CURRENT', 'rptbilling', 'BRGY_SHARE', 'BRGY SHARE CURRENT', NULL, '50000', NULL, NULL, '2018-02-28 23:44:28', 'USR-ADMIN', 'ADMIN', '1', 'ac227d9e542e0808a2333b662fea0678');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-4b72', 'DEPLOYED', 'BRGY_SHARE_PREVIOUS_PENALTY', 'rptbilling', 'BRGY_SHARE', 'BRGY SHARE PREVIOUS PENALTY', NULL, '50000', NULL, NULL, '2018-02-28 23:30:41', 'USR-ADMIN', 'ADMIN', '1', 'b2c549fa17e75c029bb209e5a715e4e8');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-4bf1', 'DEPLOYED', 'BRGY_SHARE_PREVIOUS', 'rptbilling', 'BRGY_SHARE', 'BRGY SHARE PREVIOUS', NULL, '50000', NULL, NULL, '2018-02-28 23:30:19', 'USR-ADMIN', 'ADMIN', '1', 'a8c380a00e49e5c29cf80adcd38c5b46');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-78fba29f:161df51b937:-74da', 'DEPLOYED', 'BUILD_BILL_ITEMS', 'rptbilling', 'AFTER_SUMMARY', 'BUILD BILL ITEMS', NULL, '50000', NULL, NULL, '2018-02-28 19:29:58', 'USR-ADMIN', 'ADMIN', '1', 'cf9571c62b8c5cb13c1d8d537096d92d');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-1ed3', 'DEPLOYED', 'RECALC_RPU_TOTAL_AV', 'machassessment', 'AFTER-SUMMARY', 'RECALC RPU TOTAL AV', NULL, '60000', NULL, NULL, '2017-07-01 00:21:58', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '3a9587665b36926b01dceb24d7ceba2c');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-2167', 'DEPLOYED', 'CALC_TOTAL_ASSESSEMENT_AV', 'machassessment', 'AFTER-SUMMARY', 'CALC TOTAL ASSESSEMENT AV', NULL, '50000', NULL, NULL, '2017-07-01 00:19:56', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '629cc5ae5670bcabb4566202b98b97da');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-55fd', 'DEPLOYED', 'CALC_TOTAL_ASSESSEMENT_AV', 'landassessment', 'AFTER-SUMMARY', 'CALC TOTAL ASSESSEMENT AV', NULL, '50000', NULL, NULL, '2017-06-30 23:32:46', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'de2c9048b74c193249e914a932e4ce9f');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-6401', 'DEPLOYED', 'CALC_TOTAL_ASSESSEMENT_AV', 'bldgassessment', 'AFTER-SUMMARY', 'CALC TOTAL ASSESSEMENT AV', NULL, '40000', NULL, NULL, '2017-06-30 23:16:02', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '0601cefa86af03531dd6e12cd24af05d');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-6f2a', 'DEPLOYED', 'RECALC_TOTAL_AV', 'bldgassessment', 'AFTER-SUMMARY', 'RECALC TOTAL AV', NULL, '50000', NULL, NULL, '2017-06-30 23:09:32', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '707589ab75ce153d4118b4c0a9535e77');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-707b', 'DEPLOYED', 'CALC_ASSESS_VALUE_NOT_ROUNDED', 'bldgassessment', 'ASSESSVALUE', 'CALC ASSESS VALUE NOT ROUNDED', NULL, '50000', NULL, NULL, '2017-06-30 23:08:05', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'ba83710ce13d4b804b0dc2725af3e4d8');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:-b33', 'DEPLOYED', 'CALC_AV', 'machassessment', 'ASSESSEDVALUE', 'CALC AV', NULL, '50000', NULL, NULL, '2017-07-01 00:34:56', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '1c7a43765416e36b0cd568f1527b8756');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:4f83', 'DEPLOYED', 'CALC_TOTAL_ASSESSEMENT_AV', 'planttreeassessment', 'AFTER-SUMMARY', 'CALC_TOTAL_ASSESSEMENT_AV', NULL, '50000', NULL, NULL, '2017-07-01 01:09:50', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'f7f0b1f43c24448f060f9de59deb8f2f');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:549e', 'DEPLOYED', 'RECALC_TOTAL_AV', 'planttreeassessment', 'AFTER-SUMMARY', 'RECALC_TOTAL_AV', NULL, '60000', NULL, NULL, '2017-07-01 01:11:14', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '5d5cbaf180844c925c2eab4d36c73dca');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-79a9a347:15cfcae84de:f6c', 'DEPLOYED', 'CALC_AV', 'planttreeassessment', 'ASSESSEDVALUE', 'CALC AV', NULL, '50000', NULL, NULL, '2017-07-01 01:05:19', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'ee582da135031d043aa9e3097d1de7e2');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-7deff7e5:161b60a3048:-5a7e', 'DEPLOYED', 'SPLIT_QUARTERLY_BILLED_ITEMS', 'rptbilling', 'BEFORE_SUMMARY', 'SPLIT_QUARTERLY_BILLED_ITEMS', NULL, '50000', NULL, NULL, '2018-02-20 19:12:26', 'USR-79408dab:14a4c0eb004:-7fe1', 'ADMIN', '1', 'e08af09234d9188caff9e55d279f523d');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL-a35dd35:14e51ec3311:-5d4c', 'DEPLOYED', 'CALC_RPU_SWORN_AMOUNT', 'miscassessment', 'BEFORE-ASSESSLEVEL', 'CALC RPU SWORN AMOUNT', NULL, '50000', NULL, NULL, '2015-07-02 20:32:32', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '4768b10b159d92988df1dfac346fa0ce');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1441128c:1471efa4c1c:-6c93', 'DEPLOYED', 'CALC_ASSESS_LEVEL', 'bldgassessment', 'AFTER-ASSESSLEVEL', 'CALC ASSESS LEVEL', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'b8cb080c5dc61f678c2833ccf4f43987');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1441128c:1471efa4c1c:-6eaa', 'DEPLOYED', 'BUILD_ASSESSMENT_INFO', 'bldgassessment', 'BEFORE-ASSESSLEVEL', 'BUILD ASSESSMENT INFO', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '0cc01d394ee3e37c5453a81162183f77');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1b4af871:14e3cc46e09:-301e', 'DEPLOYED', 'TOTAL_MARKET_VALUE', 'miscassessment', 'AFTER-MARKETVALUE', 'TOTAL MARKET VALUE', NULL, '50000', NULL, NULL, '2015-06-28 19:30:12', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '687d7b5b933d5b53b43698522e10a23f');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1b4af871:14e3cc46e09:-3341', 'DEPLOYED', 'TOTAL_BASE_MARKET_VALUE', 'miscassessment', 'AFTER-BASEMARKETVALUE', 'TOTAL BASE MARKET VALUE', NULL, '50000', NULL, NULL, '2015-06-28 19:13:15', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'dfe574e0684fbce898c611d5f3c9b976');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e772168:14c5a447e35:-669c', 'DEPLOYED', 'ROUND_DEPRECATION_TO_NEAREST_ONE', 'machassessment', 'AFTER-DEPRECIATION', 'ROUND DEPRECATION TO NEAREST ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:48', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '06dfa342ae53a497edc24488fa912970');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e772168:14c5a447e35:-6d2f', 'DEPLOYED', 'ROUND_MV_TO_NEAREST_ONE', 'machassessment', 'AFTER-MARKETVALUE', 'ROUND MV TO NEAREST ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:48', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '8a4a2fabaece075e38fae336166ec7b8');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e772168:14c5a447e35:-7e01', 'DEPLOYED', 'ROUND_BMV_TO_NEAREST_ONE', 'machassessment', 'AFTER-BASEMARKETVALUE', 'ROUND BMV TO NEAREST ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:48', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '31b89faf6fee462da02c63e45832d378');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e983c10:147f2149816:2bc', 'DEPLOYED', 'TOTAL_PREVIOUS', 'rptbilling', 'SUMMARY', 'Total Previous', NULL, '50000', NULL, NULL, '2014-12-15 21:03:31', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'a1b97a56be62c883b586f5d719db2e88');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e983c10:147f2149816:437', 'DEPLOYED', 'TOTAL_CURRENT', 'rptbilling', 'SUMMARY', 'Total Current', NULL, '50000', NULL, NULL, '2014-12-15 21:03:32', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '148b4b949ba9624c4405e9a03fff7705');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL1e983c10:147f2149816:5a3', 'DEPLOYED', 'TOTAL_ADVANCE', 'rptbilling', 'SUMMARY', 'Total Advance', NULL, '50000', NULL, NULL, '2014-12-15 21:03:32', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '27a6718769d3a3dc3b27ba0dad34bb5d');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL37df8403:14c5405fff0:-76bf', 'DEPLOYED', 'BMV_ROUND_TO_ONE', 'planttreeassessment', 'AFTER-BASEMARKETVALUE', 'BMV ROUND TO ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:59', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'e3206394bb29e0e43b5f56ef9d5ef4df');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3b800abe:14d2b978f55:-61fb', 'DEPLOYED', 'ROUND_ACTUALUSE_MV_TO_ONES', 'bldgassessment', 'AFTER-MARKETVALUE', 'ROUND ACTUALUSE MV TO ONES', NULL, '50000', NULL, NULL, '2015-05-06 16:49:34', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '36bf508371b5e5127b668c03199e550c');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3b800abe:14d2b978f55:-63a0', 'DEPLOYED', 'ROUND_FLOOR_MV_TO_ONES', 'bldgassessment', 'AFTER-MARKETVALUE', 'ROUND FLOOR MV TO ONES', NULL, '50000', NULL, NULL, '2015-05-06 16:48:41', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'd0b1678414788e2a22727c5c1214aa9b');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3b800abe:14d2b978f55:-7e09', 'DEPLOYED', 'ROUND_ADJ_TO_ONES', 'bldgassessment', 'AFTER-ADJUSTMENT', 'ROUND ADJ TO ONES', NULL, '50000', NULL, NULL, '2015-05-06 16:40:20', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'c73b81d6f759aa33d73d121bfee9edff');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3de2e0bf:15165926561:-7bfc', 'DEPLOYED', 'SPLIT_QTR', 'rptbilling', 'INIT', 'SPLIT QTR', NULL, '50000', NULL, NULL, '2015-12-02 18:27:33', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'a9ea1429b03c10fed24a88c1943e7c1e');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3e2b89cb:146ff734573:-7dcc', 'DEPLOYED', 'COMPUTE_BLDG_AGE', 'bldgassessment', 'PRE-ASSESSMENT', 'COMPUTE BLDG AGE', NULL, '50000', NULL, NULL, '2014-12-15 20:59:15', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '3d1cf99ac13438a5282b3fb64e57cbd6');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL3fb43b91:14ccf782188:-6008', 'DEPLOYED', 'ADJUSTMENT_COMPUTATION', 'planttreeassessment', 'AFTER-ADJUSTMENT', 'ADJUSTMENT COMPUTATION', NULL, '50000', NULL, NULL, '2015-04-18 20:11:31', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '13662cfd4054aad1e9bca02a47af48af');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL49a3c540:14e51feb8f6:-77d2', 'DEPLOYED', 'CALC_RPU_APPRAISAL', 'miscassessment', 'BEFORE-ASSESSLEVEL', 'CALC RPU APPRAISAL', NULL, '50000', NULL, NULL, '2015-07-02 20:44:36', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'af0aa684ee09751278a44d896c28bd92');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL4bf973aa:1562a233196:-5055', 'DEPLOYED', 'CALC_SWORN_DEPRECIATION_VALUE', 'machassessment', 'DEPRECIATION', 'CALC SWORN DEPRECIATION VALUE', NULL, '50000', NULL, NULL, '2016-07-26 19:47:02', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '6b8c0dc040ebec0ae182add21d9c4924');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL4e46261d:14f924c6b53:-7d9b', 'DEPLOYED', 'CALC_DEPRECIATION_SWORN', 'bldgassessment', 'DEPRECIATION', 'CALC DEPRECIATION SWORN', NULL, '50000', NULL, NULL, '2015-09-03 01:39:13', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '2797424efc5b934042c350dd2b83b251');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL4fc9c2c7:176cac860ed:-76d7', 'DEPLOYED', 'DISCOUNT_20_PERCENT_EXTENSION', 'rptbilling', 'AFTER_DISCOUNT', 'DISCOUNT_20_PERCENT_EXTENSION', NULL, '40000', '2021-01-01', '2021-03-31', '2021-01-04 08:44:08', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', '05bb8979dcd0114f4c82970a16d81169');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5022d8ba:1589ae965a4:-7c9c', 'DEPLOYED', 'BUILD_ASSESSMENT_INFO', 'planttreeassessment', 'SUMMARY', 'BUILD ASSESSMENT INFO', NULL, '50000', NULL, NULL, '2016-11-25 02:08:41', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'e105048501597e8b70572cc690b95e6c');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL59614e16:14c5e56ecc8:-7cbf', 'DEPLOYED', 'CALC_MARKET_VALUE', 'miscassessment', 'MARKETVALUE', 'CALC MARKET VALUE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:52', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '9c1cc3a84c6c59b443459bc6f68e7af9');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL59614e16:14c5e56ecc8:-7dfb', 'DEPLOYED', 'CALC_DEPRECIATION', 'miscassessment', 'DEPRECIATION', 'CALC DEPRECIATION', NULL, '50000', NULL, NULL, '2015-04-06 20:40:52', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', '07e5b75961691d4eec4d61be35734078');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5a030c2b:17277b1ddc5:-7e65', 'DEPLOYED', 'PENALTY_2015_TO_2018_ADJUSTMENT', 'rptbilling', 'AFTER_PENALTY', 'PENALTY 2015 TO 2018 ADJUSTMENT', NULL, '40000', NULL, '2021-05-08', '2020-06-03 08:54:20', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', '2686b4d4381b265654c72270a7cef286');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5b4ac915:147baaa06b4:-6f31', 'DEPLOYED', 'BUILD_ASSESSMENT_INFO_SPLIT', 'landassessment', 'SUMMARY', 'BUILD_ASSESSMENT_INFO_SPLIT', NULL, '50000', NULL, NULL, '2014-12-15 20:59:22', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '15d44e4df65a043075388e61e1382d25');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5b84d618:1615428187f:-62e3', 'DEPLOYED', 'DISCOUNT_ADVANCE', 'rptbilling', 'DISCOUNT', 'DISCOUNT ADVANCE', NULL, '50000', NULL, NULL, '2018-02-01 19:52:45', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'a6553099aebfcaf9e4fa5f5e76fad3ea');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5b84d618:1615428187f:-67ce', 'DEPLOYED', 'DISCOUNT_CURRENT', 'rptbilling', 'DISCOUNT', 'DISCOUNT CURRENT', NULL, '50000', NULL, NULL, '2018-02-01 19:51:14', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '07cdf0fcb1dc0f04baa5f1db51458a7b');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5d750d7e:161889cc785:-5f54', 'DEPLOYED', 'EXPIRY_DATE_ADVANCE_YEAR_ABOVE', 'rptbilling', 'BEFORE_SUMMARY', 'EXPIRY DATE ADVANCE YEAR ABOVE CY + 1 ', NULL, '30000', NULL, NULL, '2018-02-11 23:38:14', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '8106ca784d254cf56797458752118128');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5d750d7e:161889cc785:-61f2', 'DEPLOYED', 'EXPIRY_DATE_ADVANCE_YEAR', 'rptbilling', 'BEFORE_SUMMARY', 'EXPIRY DATE ADVANCE YEAR', NULL, '30000', NULL, NULL, '2018-02-11 23:30:08', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '91e9ef926554f8300e7d8ef6741b7ded');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5d750d7e:161889cc785:-72c0', 'DEPLOYED', 'EXPIRY_DATE_DEFAULT', 'rptbilling', 'BEFORE_SUMMARY', 'DEFAULT EXPIRY DATE', NULL, '50000', NULL, NULL, '2018-02-11 22:47:08', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '4ab9de3bef78d5256a947bb3775b7458');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL5d750d7e:161889cc785:-7301', 'DEPLOYED', 'EXPIRY_DATE_CURRENT_YEAR_UPDATED', 'rptbilling', 'BEFORE_SUMMARY', 'EXPIRY DATE CURRENT YEAR UPDATED', NULL, '20000', NULL, NULL, '2018-02-11 22:46:53', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '2f1ef2ed8ee8d6db2a596574b90e6e1c');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL634d9a3c:161503ff1dc:-5b2a', 'DEPLOYED', 'BASIC_SEF_TAX', 'rptledger', 'TAX', 'BASIC SEF TAX', NULL, '50000', NULL, NULL, '2018-02-01 01:47:23', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '0ffa03ef9f3fc2bb3657c7404732f3a7');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL650f832b:14c53e6ce93:-79cd', 'DEPLOYED', 'MV_ROUND_TO_ONE', 'planttreeassessment', 'AFTER-MARKETVALUE', 'MV ROUND TO ONE', NULL, '50000', NULL, NULL, '2015-04-06 20:40:59', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'c5e5daf24c798d93313cb2674642327e');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL6afb50c:1724e644945:-602d', 'DEPLOYED', 'DISCOUNT_EXTENSION_DUE_TO_COVID', 'rptbilling', 'AFTER_DISCOUNT', 'DISCOUNT EXTENSION DUE TO COVID', NULL, '40000', NULL, '2020-06-25', '2020-05-26 11:27:10', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', '28ff633461269d7906035658c239cbca');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL6afb50c:1724e644945:-62f2', 'DEPLOYED', 'DISCOUNT_QTRLY_MISSPAYMENT_ADJUSTMENT', 'rptbilling', 'AFTER_DISCOUNT', 'DISCOUNT QTRLY MISSPAYMENT ADJUSTMENT', NULL, '50000', NULL, NULL, '2020-05-26 10:52:17', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', 'b72c7424674180bfccbcabf9cab37fe0');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL6afb50c:1724e644945:-6621', 'DEPLOYED', 'PENALTY_QTRLY_MISSPAYMENT_ADJUSTMENT', 'rptbilling', 'AFTER_PENALTY', 'PENALTY_QTRLY_MISSPAYMENT_ADJUSTMENT', NULL, '50000', NULL, NULL, '2020-05-26 10:48:25', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', '858a74eb994d771db6e9215a705b40bf');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL6afb50c:1724e644945:-6b4e', 'DEPLOYED', 'PENALTY_BASIC_SEF_CY', 'rptbilling', 'PENALTY', 'PENALTY_BASIC_SEF_CY', NULL, '50000', NULL, NULL, '2020-05-26 10:45:02', 'USR6a00fbba:161f40872da:-7e62', 'RYANEZA', '1', 'fbc3d87ff24542fd373e6583e09ff6b9');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL6d174068:14e3de9c20b:-7fcb', 'DEPLOYED', 'CALC_RPU_ASSESSED_VALUE', 'miscassessment', 'ASSESSEDVALUE', 'CALC RPU ASSESSED VALUE', NULL, '50000', NULL, NULL, '2015-06-28 23:04:44', 'USR-5596bc96:149114d7d7c:-4468', 'VINZ', '1', 'b6b4fdf80ee2640ca34e23e471002a74');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-54ee', 'DEPLOYED', 'PROV_SEF_SHARE_PREVIOUS', 'rptbilling', 'LGU_SHARE', 'PROV SEF SHARE PREVIOUS', NULL, '50000', NULL, NULL, '2018-03-08 22:53:28', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '69b0b28d672219521604c6e2e683b831');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-5520', 'DEPLOYED', 'PROV_SEF_SHARE_PREVIOUS_PENALTY', 'rptbilling', 'LGU_SHARE', 'PROV SEF SHARE PREVIOUS PENALTY', NULL, '50000', NULL, NULL, '2018-03-08 22:53:16', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '25347e8942cb810b6ab838e2725f1624');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-5552', 'DEPLOYED', 'PROV_SEF_SHARE_CURRENT', 'rptbilling', 'LGU_SHARE', 'PROV SEF SHARE CURRENT', NULL, '50000', NULL, NULL, '2018-03-08 22:53:04', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'ede92fb1b1ce6e1aae468b2cca81e246');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-5584', 'DEPLOYED', 'PROV_SEF_SHARE_CURRENT_PENALTY', 'rptbilling', 'LGU_SHARE', 'PROV SEF SHARE CURRENT PENALTY', NULL, '50000', NULL, NULL, '2018-03-08 22:52:46', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'b851a4615b6a154bf5212177ff59b4fd');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-583b', 'DEPLOYED', 'PROV_SEF_SHARE_ADVANCE', 'rptbilling', 'LGU_SHARE', 'PROV SEF SHARE ADVANCE', NULL, '50000', NULL, NULL, '2018-03-08 22:49:36', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'cead24c5e9a07b02d913ace0509db0c9');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-588e', 'DEPLOYED', 'PROV_BASIC_SHARE_ADVANCE', 'rptbilling', 'LGU_SHARE', 'PROV BASIC SHARE ADVANCE', NULL, '50000', NULL, NULL, '2018-03-08 22:49:11', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '1b93577459d89b5be0179aa6eeedb46f');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-58d7', 'DEPLOYED', 'PROV_BASIC_SHARE_CURRENT_PENALTY', 'rptbilling', 'LGU_SHARE', 'PROV BASIC SHARE CURRENT PENALTY', NULL, '50000', NULL, NULL, '2018-03-08 22:48:57', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '959dc0a0bf710feee863b674dbb640fe');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-5939', 'DEPLOYED', 'PROV_BASIC_SHARE_CURRENT', 'rptbilling', 'LGU_SHARE', 'PROV BASIC SHARE CURRENT', NULL, '50000', NULL, NULL, '2018-03-08 22:48:39', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'b57f3d4793a55c7bf1bf0b93931249e8');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-5972', 'DEPLOYED', 'PROV_BASIC_SHARE_PREVIOUS_PENALTY', 'rptbilling', 'LGU_SHARE', 'PROV BASIC SHARE PREVIOUS PENALTY', NULL, '50000', NULL, NULL, '2018-03-08 22:48:25', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', 'e87e0e690c8312831b8fcc002e2b5ad2');
REPLACE INTO `sys_rule` (`objid`, `state`, `name`, `ruleset`, `rulegroup`, `title`, `description`, `salience`, `effectivefrom`, `effectiveto`, `dtfiled`, `user_objid`, `user_name`, `noloop`, `_ukey`) VALUES ('RUL713e35a1:1620963487c:-59d5', 'DEPLOYED', 'PROV_BASIC_SHARE_PREVIOUS', 'rptbilling', 'LGU_SHARE', 'PROV BASIC SHARE PREVIOUS', NULL, '50000', NULL, NULL, '2018-03-08 22:48:04', 'USR7e15465b:14a51353b1a:-7fb7', 'ADMIN', '1', '60ae03aa071be2359467f752af8143e0');

REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-2486b0ca:146fff66c3e:-2c4a', '\npackage bldgassessment.CALC_ACTUAL_USE_MV;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_ACTUAL_USE_MV\"\n	agenda-group \"MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BU: rptis.bldg.facts.BldgUse (  BMV:basemarketvalue,DEP:depreciationvalue,ADJ:adjustment ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"DEP\", DEP );\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV + ADJ - DEP  )\", bindings)) );\r\naction.execute( \"calc-bldguse-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-2486b0ca:146fff66c3e:-38e4', '\npackage bldgassessment.CALC_FLOOR_MARKET_VALUE;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_FLOOR_MARKET_VALUE\"\n	agenda-group \"BEFORE-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BF: rptis.bldg.facts.BldgFloor (  BMV:basemarketvalue,ADJ:adjustment ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BF\", BF );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldgfloor\", BF );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV + ADJ )\", bindings)) );\r\naction.execute( \"calc-floor-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-2486b0ca:146fff66c3e:-4192', '\npackage bldgassessment.CALC_DEPRECIATION;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_DEPRECIATION\"\n	agenda-group \"DEPRECIATION\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RPU: rptis.bldg.facts.BldgRPU (  DPRATE:depreciation ) \n		\n		BU: rptis.bldg.facts.BldgUse (  BMV:basemarketvalue,ADJUSTMENT:adjustment,useswornamount == false  ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"DPRATE\", DPRATE );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"ADJUSTMENT\", ADJUSTMENT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( (BMV + ADJUSTMENT ) * DPRATE   / 100.0  , 0)\", bindings)) );\r\naction.execute( \"calc-bldguse-depreciation\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-2486b0ca:146fff66c3e:-4697', '\npackage bldgassessment.CALC_DEPRECATION_RATE_FROM_SKED;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_DEPRECATION_RATE_FROM_SKED\"\n	agenda-group \"BEFORE-DEPRECIATON\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BS: rptis.bldg.facts.BldgStructure (   ) \n		\n		RPU: rptis.bldg.facts.BldgRPU (   ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BS\", BS );\n		\n		bindings.put(\"RPU\", RPU );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldgstructure\", BS );\r\naction.execute( \"calc-depreciation-range\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-2486b0ca:146fff66c3e:-6b05', '\npackage bldgassessment.CALC_FLOOR_BMV;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_FLOOR_BMV\"\n	agenda-group \"FLOOR\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BF: rptis.bldg.facts.BldgFloor (  AREA:area,UV:unitvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BF\", BF );\n		\n		bindings.put(\"AREA\", AREA );\n		\n		bindings.put(\"UV\", UV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldgfloor\", BF );\r\n_p0.put( \"expr\", (new ActionExpression(\"AREA * UV\", bindings)) );\r\naction.execute( \"calc-floor-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-31fc82f2:15cf6ecbe4d:-6b3d', '\npackage landassessment.COMPUTE_AV_NOT_ROUND;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"COMPUTE_AV_NOT_ROUND\"\n	agenda-group \"ASSESSEDVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		LA: rptis.land.facts.LandDetail (  MV:marketvalue,AL:assesslevel ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"LA\", LA );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"AL\", AL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"landdetail\", LA );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN( MV * AL / 100.0)\", bindings)) );\r\naction.execute( \"calc-av\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-3e8edbea:156bc08656a:-5f05', '\npackage landassessment.RECALC_RPU_TOTAL_AV;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"RECALC_RPU_TOTAL_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 40000\n	no-loop\n	when\n		\n		\n		RPU: rptis.facts.RPU (   ) \n		\n		VAR: rptis.facts.RPTVariable (  varid matches \"RP-28dc975:156bcab666c:-6a4d\",AV:value ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"VAR\", VAR );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN( AV  )\", bindings)) );\r\naction.execute( \"recalc-rpu-totalav\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-46fca07e:14c545f3e6a:-33b4', '\npackage bldgassessment.ROUND_FLOOR_BMV_TO_NEAREST_ONES;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_FLOOR_BMV_TO_NEAREST_ONES\"\n	agenda-group \"AFTER-BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BF: rptis.bldg.facts.BldgFloor (  BMV:basemarketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BF\", BF );\n		\n		bindings.put(\"BMV\", BMV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldgfloor\", BF );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV, 0)\", bindings)) );\r\naction.execute( \"calc-floor-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-46fca07e:14c545f3e6a:-350f', '\npackage bldgassessment.ROUND_ACTUALUSE_BMV_TO_NEAREST_ONE;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_ACTUALUSE_BMV_TO_NEAREST_ONE\"\n	agenda-group \"AFTER-BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BU: rptis.bldg.facts.BldgUse (  BMV:basemarketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"BMV\", BMV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(BMV, 0)\", bindings)) );\r\naction.execute( \"calc-bldguse-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-46fca07e:14c545f3e6a:-7740', '\npackage landassessment.CALC_MV;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_MV\"\n	agenda-group \"MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		LA: rptis.land.facts.LandDetail (  BMV:basemarketvalue,ADJ:adjustment ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"LA\", LA );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"landdetail\", LA );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV + ADJ, 2)\", bindings)) );\r\naction.execute( \"calc-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-46fca07e:14c545f3e6a:-7a8b', '\npackage landassessment.CALC_BMV;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_BMV\"\n	agenda-group \"BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		LA: rptis.land.facts.LandDetail (  AREA:area,UV:unitvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"LA\", LA );\n		\n		bindings.put(\"AREA\", AREA );\n		\n		bindings.put(\"UV\", UV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"landdetail\", LA );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( AREA * UV, 2)\", bindings)) );\r\naction.execute( \"calc-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-585c89e6:16156f39eeb:-770f', '\npackage rptbilling.AGGREGATE_PREVIOUS_ITEMS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"AGGREGATE_PREVIOUS_ITEMS\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year < CY,qtrly == true  ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\naction.execute( \"aggregate-bill-item\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-59249a93:1614f57bd58:-7d49', '\npackage rptledger.BASIC_AND_SEF;\nimport rptledger.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BASIC_AND_SEF\"\n	agenda-group \"LEDGER_ITEM\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		AVINFO: rptis.landtax.facts.AssessedValue (  YR:year,AV:av ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"AVINFO\", AVINFO );\n		\n		bindings.put(\"YR\", YR );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"avfact\", AVINFO );\r\n_p0.put( \"year\", YR );\r\n_p0.put( \"av\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-sef\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"avfact\", AVINFO );\r\n_p1.put( \"year\", YR );\r\n_p1.put( \"av\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-basic\",_p1,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-5e76cf73:14d69e9c549:-7084', '\npackage landassessment.ROUND_LAND_ITEM_ADJUSTMENTS;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_LAND_ITEM_ADJUSTMENTS\"\n	agenda-group \"AFTER-ADJUSTMENT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		LA: rptis.land.facts.LandDetail (  ADJ:adjustment,LVADJ:landvalueadjustment,AUADJ:actualuseadjustment ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"LA\", LA );\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n		bindings.put(\"LVADJ\", LVADJ );\n		\n		bindings.put(\"AUADJ\", AUADJ );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"landdetail\", LA );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( LVADJ, 2)\", bindings)) );\r\naction.execute( \"update-landdetail-value-adj\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"landdetail\", LA );\r\n_p1.put( \"expr\", (new ActionExpression(\"@ROUND( AUADJ, 2)\", bindings)) );\r\naction.execute( \"update-landdetail-actualuse-adj\",_p1,drools);\r\nMap _p2 = new HashMap();\r\n_p2.put( \"landdetail\", LA );\r\n_p2.put( \"expr\", (new ActionExpression(\"@ROUND( ADJ, 2)\", bindings)) );\r\naction.execute( \"update-landdetail-adj\",_p2,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-5e76cf73:14d69e9c549:-7fd4', '\npackage landassessment.ROUND_ADJ_TO_ONE;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_ADJ_TO_ONE\"\n	agenda-group \"AFTER-ADJUSTMENT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		ADJ: rptis.land.facts.LandAdjustment (  ADJAMOUNT:adjustment ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n		bindings.put(\"ADJAMOUNT\", ADJAMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"adjustment\", ADJ );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( ADJAMOUNT, 2)\", bindings)) );\r\naction.execute( \"update-adj\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-60c99d04:1470b276e7f:-7ecc', '\npackage bldgassessment.CALC_BMV;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_BMV\"\n	agenda-group \"BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BS: rptis.bldg.facts.BldgStructure (  TOTALAREA:totalfloorarea ) \n		\n		BU: rptis.bldg.facts.BldgUse (  bldgstructure == BS,BASEVALUE:basevalue,BUAREA:area ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BS\", BS );\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"TOTALAREA\", TOTALAREA );\n		\n		bindings.put(\"BASEVALUE\", BASEVALUE );\n		\n		bindings.put(\"BUAREA\", BUAREA );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BUAREA * BASEVALUE  )\", bindings)) );\r\naction.execute( \"calc-bldguse-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-621d5f20:16222e9bf6d:-19d5', '\npackage rptbilling.PENALTY_BASIC_SEF_LESS_CY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PENALTY_BASIC_SEF_LESS_CY\"\n	agenda-group \"PENALTY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year < CY,NMON:monthsfromjan,revtype matches \"basic|sef\",TAX:amtdue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"NMON\", NMON );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"@IIF( NMON * 0.02 > 0.72 , TAX * 0.72 , TAX * NMON * 0.02  )\", bindings)) );\r\naction.execute( \"calc-interest\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-621d5f20:16222e9bf6d:-bc0', '\npackage rptbilling.DISCOUNT_CURRENT_QTRLY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_CURRENT_QTRLY\"\n	agenda-group \"DISCOUNT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr > 1 ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,TAX:amtdue,qtr >= CQTR ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * 0.10\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-6c4ec747:154bd626092:-5616', '\npackage machassessment.CALC_BMV_BY_SWORN_STATEMENT;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_BMV_BY_SWORN_STATEMENT\"\n	agenda-group \"BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MACH: rptis.mach.facts.MachineDetail (  useswornamount == true ,SWORNAMT:swornamount ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"SWORNAMT\", SWORNAMT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(SWORNAMT, 0)\", bindings)) );\r\naction.execute( \"calc-mach-mv\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"machine\", MACH );\r\n_p1.put( \"expr\", (new ActionExpression(\"@ROUND(SWORNAMT, 0)\", bindings)) );\r\naction.execute( \"calc-mach-bmv\",_p1,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-762e9176:15d067a9c42:-5aa0', '\npackage miscassessment.RECALC_RPU_TOTAL_AV;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"RECALC_RPU_TOTAL_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 60000\n	no-loop\n	when\n		\n		\n		VAR: rptis.facts.RPTVariable (  varid matches \"P-79a9a347:15cfcae84de:-5edb\",TOTALAV:value ) \n		\n		RPU: rptis.facts.RPU (   ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"VAR\", VAR );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"TOTALAV\", TOTALAV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN( TOTALAV)\", bindings)) );\r\naction.execute( \"recalc-rpu-totalav\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-762e9176:15d067a9c42:-5e26', '\npackage miscassessment.CALC_TOTAL_ASSESSEMENT_AV;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_TOTAL_ASSESSEMENT_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RA: rptis.facts.RPUAssessment (  actualuseid != null,AV:assessedvalue ) \n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RA\", RA );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", RPUID );\r\n_p0.put( \"var\", new KeyValue(\"P-79a9a347:15cfcae84de:-5edb\", \"TOTAL_AV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-4837', '\npackage rptbilling.BRGY_SHARE_ADVANCE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BRGY_SHARE_ADVANCE\"\n	agenda-group \"BRGY_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_ADVANCE\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  BRGYID:barangayid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"BRGYID\", BRGYID );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"barangay\" );\r\n_p0.put( \"orgid\", BRGYID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_ADVANCE_BRGY_SHARE\", \"RPT BASIC ADVANCE BARANGAY SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\" AMOUNT \", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.25\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-4951', '\npackage rptbilling.BRGY_SHARE_CURRENT_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BRGY_SHARE_CURRENT_PENALTY\"\n	agenda-group \"BRGY_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASICINT_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  BRGYID:barangayid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"BRGYID\", BRGYID );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"barangay\" );\r\n_p0.put( \"orgid\", BRGYID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASICINT_CURRENT_BRGY_SHARE\", \"RPT BASIC PENALTY CURRENT BARANGAY SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.25\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-4a59', '\npackage rptbilling.BRGY_SHARE_CURRENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BRGY_SHARE_CURRENT\"\n	agenda-group \"BRGY_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  BRGYID:barangayid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"BRGYID\", BRGYID );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"barangay\" );\r\n_p0.put( \"orgid\", BRGYID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_CURRENT_BRGY_SHARE\", \"RPT BASIC CURRENT BARANGAY SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\" AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.25\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-4b72', '\npackage rptbilling.BRGY_SHARE_PREVIOUS_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BRGY_SHARE_PREVIOUS_PENALTY\"\n	agenda-group \"BRGY_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASICINT_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  BRGYID:barangayid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"BRGYID\", BRGYID );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"barangay\" );\r\n_p0.put( \"orgid\", BRGYID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASICINT_PREVIOUS_BRGY_SHARE\", \"RPT BASIC PENALTY PREVIOUS BARANGAY SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.25\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-4bf1', '\npackage rptbilling.BRGY_SHARE_PREVIOUS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BRGY_SHARE_PREVIOUS\"\n	agenda-group \"BRGY_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  BRGYID:barangayid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"BRGYID\", BRGYID );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"barangay\" );\r\n_p0.put( \"orgid\", BRGYID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_PREVIOUS_BRGY_SHARE\", \"RPT BASIC PREVIOUS BARANGAY SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.25\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-78fba29f:161df51b937:-74da', '\npackage rptbilling.BUILD_BILL_ITEMS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BUILD_BILL_ITEMS\"\n	agenda-group \"AFTER_SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RLTS: rptis.landtax.facts.RPTLedgerTaxSummaryFact (   ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RLTS\", RLTS );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"taxsummary\", RLTS );\r\naction.execute( \"add-billitem\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-1ed3', '\npackage machassessment.RECALC_RPU_TOTAL_AV;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"RECALC_RPU_TOTAL_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 60000\n	no-loop\n	when\n		\n		\n		RPU: rptis.facts.RPU (   ) \n		\n		VAR: rptis.facts.RPTVariable (  varid matches \"P-79a9a347:15cfcae84de:-5edb\",TOTALAV:value ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"VAR\", VAR );\n		\n		bindings.put(\"TOTALAV\", TOTALAV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN(TOTALAV)\", bindings)) );\r\naction.execute( \"recalc-rpu-totalav\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-2167', '\npackage machassessment.CALC_TOTAL_ASSESSEMENT_AV;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_TOTAL_ASSESSEMENT_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RA: rptis.facts.RPUAssessment (  actualuseid != null,AV:assessedvalue ) \n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RA\", RA );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", RPUID );\r\n_p0.put( \"var\", new KeyValue(\"P-79a9a347:15cfcae84de:-5edb\", \"TOTAL_AV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-55fd', '\npackage landassessment.CALC_TOTAL_ASSESSEMENT_AV;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_TOTAL_ASSESSEMENT_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RA: rptis.facts.RPUAssessment (  actualuseid != null,AV:assessedvalue,taxable == true  ) \n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RA\", RA );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", RPUID );\r\n_p0.put( \"var\", new KeyValue(\"RP-28dc975:156bcab666c:-6a4d\", \"TOTALAV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-6401', '\npackage bldgassessment.CALC_TOTAL_ASSESSEMENT_AV;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_TOTAL_ASSESSEMENT_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 40000\n	no-loop\n	when\n		\n		\n		RA: rptis.facts.RPUAssessment (  actualuseid != null,AV:assessedvalue ) \n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RA\", RA );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", RPUID );\r\n_p0.put( \"var\", new KeyValue(\"P-79a9a347:15cfcae84de:-5edb\", \"TOTAL_AV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-6f2a', '\npackage bldgassessment.RECALC_TOTAL_AV;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"RECALC_TOTAL_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n		VAR: rptis.facts.RPTVariable (  varid matches \"P-79a9a347:15cfcae84de:-5edb\",AV:value ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"VAR\", VAR );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN(AV );\", bindings)) );\r\naction.execute( \"recalc-rpu-totalav\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-707b', '\npackage bldgassessment.CALC_ASSESS_VALUE_NOT_ROUNDED;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_ASSESS_VALUE_NOT_ROUNDED\"\n	agenda-group \"ASSESSVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BA: rptis.facts.RPUAssessment (  actualuseid != null,MV:marketvalue,AL:assesslevel,taxable == true  ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BA\", BA );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"AL\", AL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"assessment\", BA );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( MV * AL  / 100.0 , 2)\", bindings)) );\r\naction.execute( \"calc-assess-value\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:-b33', '\npackage machassessment.CALC_AV;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_AV\"\n	agenda-group \"ASSESSEDVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MAU: rptis.mach.facts.MachineActualUse (   ) \n		\n		MACH: rptis.mach.facts.MachineDetail (  machuse == MAU,taxable == true ,MV:marketvalue,AL:assesslevel ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MAU\", MAU );\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"AL\", AL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(MV * AL  / 100.0, 2);\", bindings)) );\r\naction.execute( \"calc-mach-av\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:4f83', '\npackage planttreeassessment.CALC_TOTAL_ASSESSEMENT_AV;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_TOTAL_ASSESSEMENT_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RA: rptis.facts.RPUAssessment (  actualuseid != null,AV:assessedvalue ) \n		\n		RPU: rptis.facts.RPU (  RPUID:objid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RA\", RA );\n		\n		bindings.put(\"RPUID\", RPUID );\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", RPUID );\r\n_p0.put( \"var\", new KeyValue(\"P-79a9a347:15cfcae84de:-5edb\", \"TOTAL_AV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:549e', '\npackage planttreeassessment.RECALC_TOTAL_AV;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"RECALC_TOTAL_AV\"\n	agenda-group \"AFTER-SUMMARY\"\n	salience 60000\n	no-loop\n	when\n		\n		\n		RPU: rptis.facts.RPU (   ) \n		\n		VAR: rptis.facts.RPTVariable (  varid matches \"P-79a9a347:15cfcae84de:-5edb\",TOTALAV:value ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"VAR\", VAR );\n		\n		bindings.put(\"TOTALAV\", TOTALAV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUNDTOTEN(TOTALAV)\", bindings)) );\r\naction.execute( \"recalc-rpu-totalav\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-79a9a347:15cfcae84de:f6c', '\npackage planttreeassessment.CALC_AV;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_AV\"\n	agenda-group \"ASSESSEDVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		PTD: rptis.planttree.facts.PlantTreeDetail (  MV:marketvalue,AL:assesslevel ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"PTD\", PTD );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"AL\", AL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"planttreedetail\", PTD );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(MV * AL / 100.0);\", bindings)) );\r\naction.execute( \"calc-planttree-av\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-7deff7e5:161b60a3048:-5a7e', '\npackage rptbilling.SPLIT_QUARTERLY_BILLED_ITEMS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"SPLIT_QUARTERLY_BILLED_ITEMS\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,qtrly == false ,revtype matches \"basic|sef\" ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\naction.execute( \"split-bill-item\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL-a35dd35:14e51ec3311:-5d4c', '\npackage miscassessment.CALC_RPU_SWORN_AMOUNT;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_RPU_SWORN_AMOUNT\"\n	agenda-group \"BEFORE-ASSESSLEVEL\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MRPU: rptis.misc.facts.MiscRPU (  useswornamount == true ,SWORNAMT:swornamount ) \n		\n		MI: rptis.misc.facts.MiscItem (  DPRATE:depreciation ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MRPU\", MRPU );\n		\n		bindings.put(\"DPRATE\", DPRATE );\n		\n		bindings.put(\"MI\", MI );\n		\n		bindings.put(\"SWORNAMT\", SWORNAMT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"miscrpu\", MRPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"SWORNAMT * (100 - DPRATE ) / 100.0\", bindings)) );\r\naction.execute( \"calc-rpu-mv\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"miscrpu\", MRPU );\r\n_p1.put( \"expr\", (new ActionExpression(\"SWORNAMT * (100 - DPRATE ) / 100.0\", bindings)) );\r\naction.execute( \"calc-rpu-bmv\",_p1,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1441128c:1471efa4c1c:-6c93', '\npackage bldgassessment.CALC_ASSESS_LEVEL;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_ASSESS_LEVEL\"\n	agenda-group \"AFTER-ASSESSLEVEL\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BA: rptis.facts.RPUAssessment (  actualuseid != null ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BA\", BA );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"assessment\", BA );\r\naction.execute( \"calc-assess-level\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1441128c:1471efa4c1c:-6eaa', '\npackage bldgassessment.BUILD_ASSESSMENT_INFO;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BUILD_ASSESSMENT_INFO\"\n	agenda-group \"BEFORE-ASSESSLEVEL\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BU: rptis.bldg.facts.BldgUse (  ACTUALUSE:actualuseid != null ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"ACTUALUSE\", ACTUALUSE );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"actualuseid\", ACTUALUSE );\r\naction.execute( \"add-assessment-info\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1b4af871:14e3cc46e09:-301e', '\npackage miscassessment.TOTAL_MARKET_VALUE;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"TOTAL_MARKET_VALUE\"\n	agenda-group \"AFTER-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MRPU: rptis.misc.facts.MiscRPU (  REFID:objid ) \n		\n		MI: rptis.misc.facts.MiscItem (  MV:marketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MRPU\", MRPU );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"REFID\", REFID );\n		\n		bindings.put(\"MI\", MI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", REFID );\r\n_p0.put( \"var\", new KeyValue(\"TOTAL_MV\", \"TOTAL_MV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"MV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1b4af871:14e3cc46e09:-3341', '\npackage miscassessment.TOTAL_BASE_MARKET_VALUE;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"TOTAL_BASE_MARKET_VALUE\"\n	agenda-group \"AFTER-BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MRPU: rptis.misc.facts.MiscRPU (  REFID:objid ) \n		\n		MI: rptis.misc.facts.MiscItem (  BMV:basemarketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MRPU\", MRPU );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"REFID\", REFID );\n		\n		bindings.put(\"MI\", MI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"refid\", REFID );\r\n_p0.put( \"var\", new KeyValue(\"TOTAL_BMV\", \"TOTAL_BMV\") );\r\n_p0.put( \"aggregatetype\", \"sum\" );\r\n_p0.put( \"expr\", (new ActionExpression(\"BMV\", bindings)) );\r\naction.execute( \"add-derive-var\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e772168:14c5a447e35:-669c', '\npackage machassessment.ROUND_DEPRECATION_TO_NEAREST_ONE;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_DEPRECATION_TO_NEAREST_ONE\"\n	agenda-group \"AFTER-DEPRECIATION\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MACH: rptis.mach.facts.MachineDetail (  DEP:depreciationvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"DEP\", DEP );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( DEP, 0)\", bindings)) );\r\naction.execute( \"calc-mach-depreciation\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e772168:14c5a447e35:-6d2f', '\npackage machassessment.ROUND_MV_TO_NEAREST_ONE;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_MV_TO_NEAREST_ONE\"\n	agenda-group \"AFTER-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MACH: rptis.mach.facts.MachineDetail (  MV:marketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"MV\", MV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( MV, 0)\", bindings)) );\r\naction.execute( \"calc-mach-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e772168:14c5a447e35:-7e01', '\npackage machassessment.ROUND_BMV_TO_NEAREST_ONE;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_BMV_TO_NEAREST_ONE\"\n	agenda-group \"AFTER-BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MACH: rptis.mach.facts.MachineDetail (  BMV:basemarketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"BMV\", BMV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV, 0)\", bindings)) );\r\naction.execute( \"calc-mach-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e983c10:147f2149816:2bc', '\npackage rptbilling.TOTAL_PREVIOUS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"TOTAL_PREVIOUS\"\n	agenda-group \"SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year < CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"revperiod\", \"previous\" );\r\naction.execute( \"create-tax-summary\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e983c10:147f2149816:437', '\npackage rptbilling.TOTAL_CURRENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"TOTAL_CURRENT\"\n	agenda-group \"SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"revperiod\", \"current\" );\r\naction.execute( \"create-tax-summary\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL1e983c10:147f2149816:5a3', '\npackage rptbilling.TOTAL_ADVANCE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"TOTAL_ADVANCE\"\n	agenda-group \"SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year > CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"revperiod\", \"advance\" );\r\naction.execute( \"create-tax-summary\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL37df8403:14c5405fff0:-76bf', '\npackage planttreeassessment.BMV_ROUND_TO_ONE;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BMV_ROUND_TO_ONE\"\n	agenda-group \"AFTER-BASEMARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		PTD: rptis.planttree.facts.PlantTreeDetail (  BMV:basemarketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"PTD\", PTD );\n		\n		bindings.put(\"BMV\", BMV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"planttreedetail\", PTD );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV, 0  )\", bindings)) );\r\naction.execute( \"calc-planttree-bmv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3b800abe:14d2b978f55:-61fb', '\npackage bldgassessment.ROUND_ACTUALUSE_MV_TO_ONES;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_ACTUALUSE_MV_TO_ONES\"\n	agenda-group \"AFTER-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BU: rptis.bldg.facts.BldgUse (  MV:marketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"MV\", MV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(MV, 0)\", bindings)) );\r\naction.execute( \"calc-bldguse-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3b800abe:14d2b978f55:-63a0', '\npackage bldgassessment.ROUND_FLOOR_MV_TO_ONES;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_FLOOR_MV_TO_ONES\"\n	agenda-group \"AFTER-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BF: rptis.bldg.facts.BldgFloor (  MV:marketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BF\", BF );\n		\n		bindings.put(\"MV\", MV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldgfloor\", BF );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( MV , 0)\", bindings)) );\r\naction.execute( \"calc-floor-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3b800abe:14d2b978f55:-7e09', '\npackage bldgassessment.ROUND_ADJ_TO_ONES;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ROUND_ADJ_TO_ONES\"\n	agenda-group \"AFTER-ADJUSTMENT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		ADJ: rptis.bldg.facts.BldgAdjustment (  bldgfloor != null,ADJAMOUNT:amount ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"ADJ\", ADJ );\n		\n		bindings.put(\"ADJAMOUNT\", ADJAMOUNT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"adjustment\", ADJ );\r\n_p0.put( \"var\", null );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND(ADJAMOUNT, 0)\", bindings)) );\r\naction.execute( \"calc-adj\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3de2e0bf:15165926561:-7bfc', '\npackage rptbilling.SPLIT_QTR;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"SPLIT_QTR\"\n	agenda-group \"INIT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,qtr > 1 ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year >= CY,qtrly == false ,revtype matches \"basic|sef\" ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\naction.execute( \"split-by-qtr\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3e2b89cb:146ff734573:-7dcc', '\npackage bldgassessment.COMPUTE_BLDG_AGE;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"COMPUTE_BLDG_AGE\"\n	agenda-group \"PRE-ASSESSMENT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RPU: rptis.bldg.facts.BldgRPU (  YRAPPRAISED:yrappraised > 0,YRCOMPLETED:yrcompleted > 0 ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"YRAPPRAISED\", YRAPPRAISED );\n		\n		bindings.put(\"YRCOMPLETED\", YRCOMPLETED );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rpu\", RPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"YRAPPRAISED - YRCOMPLETED\", bindings)) );\r\naction.execute( \"calc-bldg-age\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL3fb43b91:14ccf782188:-6008', '\npackage planttreeassessment.ADJUSTMENT_COMPUTATION;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"ADJUSTMENT_COMPUTATION\"\n	agenda-group \"AFTER-ADJUSTMENT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		PTD: rptis.planttree.facts.PlantTreeDetail (  BMV:basemarketvalue,ADJRATE:adjustmentrate ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"PTD\", PTD );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"ADJRATE\", ADJRATE );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"planttreedetail\", PTD );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV * ADJRATE / 100.0, 0)\", bindings)) );\r\naction.execute( \"calc-planttree-adjustment\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL49a3c540:14e51feb8f6:-77d2', '\npackage miscassessment.CALC_RPU_APPRAISAL;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_RPU_APPRAISAL\"\n	agenda-group \"BEFORE-ASSESSLEVEL\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MRPU: rptis.misc.facts.MiscRPU (  useswornamount == false  ) \n		\n		VAR1: rptis.facts.RPTVariable (  varid matches \"TOTAL_BMV\",TOTALBMV:value ) \n		\n		VAR2: rptis.facts.RPTVariable (  varid matches \"TOTAL_MV\",TOTALMV:value ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MRPU\", MRPU );\n		\n		bindings.put(\"VAR1\", VAR1 );\n		\n		bindings.put(\"TOTALMV\", TOTALMV );\n		\n		bindings.put(\"TOTALBMV\", TOTALBMV );\n		\n		bindings.put(\"VAR2\", VAR2 );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"miscrpu\", MRPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"TOTALMV\", bindings)) );\r\naction.execute( \"calc-rpu-mv\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"miscrpu\", MRPU );\r\n_p1.put( \"expr\", (new ActionExpression(\"TOTALBMV\", bindings)) );\r\naction.execute( \"calc-rpu-bmv\",_p1,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL4bf973aa:1562a233196:-5055', '\npackage machassessment.CALC_SWORN_DEPRECIATION_VALUE;\nimport machassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_SWORN_DEPRECIATION_VALUE\"\n	agenda-group \"DEPRECIATION\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MACH: rptis.mach.facts.MachineDetail (  SWORNAMT:swornamount,useswornamount == true ,DEPRATE:depreciation ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MACH\", MACH );\n		\n		bindings.put(\"SWORNAMT\", SWORNAMT );\n		\n		bindings.put(\"DEPRATE\", DEPRATE );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"machine\", MACH );\r\n_p0.put( \"expr\", (new ActionExpression(\"SWORNAMT * DEPRATE / 100\", bindings)) );\r\naction.execute( \"calc-mach-depreciation\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL4e46261d:14f924c6b53:-7d9b', '\npackage bldgassessment.CALC_DEPRECIATION_SWORN;\nimport bldgassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_DEPRECIATION_SWORN\"\n	agenda-group \"DEPRECIATION\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RPU: rptis.bldg.facts.BldgRPU (  DPRATE:depreciation ) \n		\n		BU: rptis.bldg.facts.BldgUse (  SWORNAMT:swornamount,ADJUSTMENT:adjustment,useswornamount == true  ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RPU\", RPU );\n		\n		bindings.put(\"SWORNAMT\", SWORNAMT );\n		\n		bindings.put(\"DPRATE\", DPRATE );\n		\n		bindings.put(\"BU\", BU );\n		\n		bindings.put(\"ADJUSTMENT\", ADJUSTMENT );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bldguse\", BU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( (SWORNAMT + ADJUSTMENT)  * DPRATE / 100.0, 0)\", bindings)) );\r\naction.execute( \"calc-bldguse-depreciation\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL4fc9c2c7:176cac860ed:-76d7', '\npackage rptbilling.DISCOUNT_20_PERCENT_EXTENSION;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_20_PERCENT_EXTENSION\"\n	agenda-group \"AFTER_DISCOUNT\"\n	salience 40000\n	no-loop\n	when\n		EffectiveDate(numericDate >= 20210101,numericDate <= 20210331)\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,TAX:amtdue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * 0.20\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5022d8ba:1589ae965a4:-7c9c', '\npackage planttreeassessment.BUILD_ASSESSMENT_INFO;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BUILD_ASSESSMENT_INFO\"\n	agenda-group \"SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		PTD: rptis.planttree.facts.PlantTreeDetail (   ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"PTD\", PTD );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"planttreedetail\", PTD );\r\naction.execute( \"add-planttree-assessment-info\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL59614e16:14c5e56ecc8:-7cbf', '\npackage miscassessment.CALC_MARKET_VALUE;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_MARKET_VALUE\"\n	agenda-group \"MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MI: rptis.misc.facts.MiscItem (  BMV:basemarketvalue,DEP:depreciatedvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MI\", MI );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"DEP\", DEP );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"miscitem\", MI );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV - DEP , 2)\", bindings)) );\r\naction.execute( \"calc-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL59614e16:14c5e56ecc8:-7dfb', '\npackage miscassessment.CALC_DEPRECIATION;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_DEPRECIATION\"\n	agenda-group \"DEPRECIATION\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MI: rptis.misc.facts.MiscItem (  BMV:basemarketvalue,DEPRATE:depreciation ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MI\", MI );\n		\n		bindings.put(\"BMV\", BMV );\n		\n		bindings.put(\"DEPRATE\", DEPRATE );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"miscitem\", MI );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( BMV * DEPRATE / 100 , 0)\", bindings)) );\r\naction.execute( \"calc-depreciation\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5a030c2b:17277b1ddc5:-7e65', '\npackage rptbilling.PENALTY_2015_TO_2018_ADJUSTMENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PENALTY_2015_TO_2018_ADJUSTMENT\"\n	agenda-group \"AFTER_PENALTY\"\n	salience 40000\n	no-loop\n	when\n		EffectiveDate(numericDate <= 20210508)\n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year >= 2015,year <= 2018 ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"0\", bindings)) );\r\naction.execute( \"calc-interest\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5b4ac915:147baaa06b4:-6f31', '\npackage landassessment.BUILD_ASSESSMENT_INFO_SPLIT;\nimport landassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BUILD_ASSESSMENT_INFO_SPLIT\"\n	agenda-group \"SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		LA: rptis.land.facts.LandDetail (  CLASS:classification != null ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"LA\", LA );\n		\n		bindings.put(\"CLASS\", CLASS );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"landdetail\", LA );\r\n_p0.put( \"classification\", CLASS );\r\naction.execute( \"add-assessment-info\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5b84d618:1615428187f:-62e3', '\npackage rptbilling.DISCOUNT_ADVANCE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_ADVANCE\"\n	agenda-group \"DISCOUNT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year > CY,TAX:amtdue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * 0.20\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5b84d618:1615428187f:-67ce', '\npackage rptbilling.DISCOUNT_CURRENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_CURRENT\"\n	agenda-group \"DISCOUNT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr == 1 ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,TAX:amtdue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * 0.10\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5d750d7e:161889cc785:-5f54', '\npackage rptbilling.EXPIRY_DATE_ADVANCE_YEAR_ABOVE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"EXPIRY_DATE_ADVANCE_YEAR_ABOVE\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 30000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  lastyearpaid > CY ) \n		\n		BILL: rptis.landtax.facts.Bill (  CURRDATE:currentdate,billtoyear > CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"CURRDATE\", CURRDATE );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"BILL\", BILL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bill\", BILL );\r\n_p0.put( \"expr\", (new ActionExpression(\"@MONTHEND(@DATE(CY, 12, 1)); \", bindings)) );\r\naction.execute( \"set-bill-expiry\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5d750d7e:161889cc785:-61f2', '\npackage rptbilling.EXPIRY_DATE_ADVANCE_YEAR;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"EXPIRY_DATE_ADVANCE_YEAR\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 30000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  lastyearpaid == CY,lastqtrpaid == 4 ) \n		\n		BILL: rptis.landtax.facts.Bill (  CURRDATE:currentdate,billtoyear > CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CURRDATE\", CURRDATE );\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"BILL\", BILL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bill\", BILL );\r\n_p0.put( \"expr\", (new ActionExpression(\"@MONTHEND(@DATE(CY, 12, 1)); \", bindings)) );\r\naction.execute( \"set-bill-expiry\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5d750d7e:161889cc785:-72c0', '\npackage rptbilling.EXPIRY_DATE_DEFAULT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"EXPIRY_DATE_DEFAULT\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILL: rptis.landtax.facts.Bill (  CDATE:currentdate ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILL\", BILL );\n		\n		bindings.put(\"CDATE\", CDATE );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bill\", BILL );\r\n_p0.put( \"expr\", (new ActionExpression(\"@MONTHEND( CDATE  )\", bindings)) );\r\naction.execute( \"set-bill-expiry\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL5d750d7e:161889cc785:-7301', '\npackage rptbilling.EXPIRY_DATE_CURRENT_YEAR_UPDATED;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"EXPIRY_DATE_CURRENT_YEAR_UPDATED\"\n	agenda-group \"BEFORE_SUMMARY\"\n	salience 20000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  LAST_YR_PAID:lastyearpaid,LAST_QTR_PAID:lastqtrpaid ) \n		\n		BILL: rptis.landtax.facts.Bill (  CURRDATE:currentdate,billtoyear == CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CURRDATE\", CURRDATE );\n		\n		bindings.put(\"LAST_YR_PAID\", LAST_YR_PAID );\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"LAST_QTR_PAID\", LAST_QTR_PAID );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"BILL\", BILL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"bill\", BILL );\r\n_p0.put( \"expr\", (new ActionExpression(\"if (LAST_YR_PAID + 1 == CY && LAST_QTR_PAID == 4 && CQTR == 1 )  return @MONTHEND(@DATE(CY, CQTR*3, 1));   if (LAST_YR_PAID == CY && LAST_QTR_PAID + 1 == CQTR )  return @MONTHEND( @DATE(CY, CQTR*3, 1));   return @MONTHEND( CURRDATE); \", bindings)) );\r\naction.execute( \"set-bill-expiry\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL634d9a3c:161503ff1dc:-5b2a', '\npackage rptledger.BASIC_SEF_TAX;\nimport rptledger.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"BASIC_SEF_TAX\"\n	agenda-group \"TAX\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  AV:av,revtype matches \"basic|sef\" ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"AV\", AV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"AV * 0.01\", bindings)) );\r\naction.execute( \"calc-tax\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL650f832b:14c53e6ce93:-79cd', '\npackage planttreeassessment.MV_ROUND_TO_ONE;\nimport planttreeassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"MV_ROUND_TO_ONE\"\n	agenda-group \"AFTER-MARKETVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		PTD: rptis.planttree.facts.PlantTreeDetail (  MV:marketvalue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"PTD\", PTD );\n		\n		bindings.put(\"MV\", MV );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"planttreedetail\", PTD );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( MV, 0  )\", bindings)) );\r\naction.execute( \"calc-planttree-mv\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL6afb50c:1724e644945:-602d', '\npackage rptbilling.DISCOUNT_EXTENSION_DUE_TO_COVID;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_EXTENSION_DUE_TO_COVID\"\n	agenda-group \"AFTER_DISCOUNT\"\n	salience 40000\n	no-loop\n	when\n		EffectiveDate(numericDate <= 20200625)\n		\n		 CurrentDate (  CY:year ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,TAX:amtdue ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"TAX\", TAX );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * 0.10\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\nMap _p1 = new HashMap();\r\n_p1.put( \"rptledgeritem\", RLI );\r\n_p1.put( \"expr\", (new ActionExpression(\"0\", bindings)) );\r\naction.execute( \"calc-interest\",_p1,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL6afb50c:1724e644945:-62f2', '\npackage rptbilling.DISCOUNT_QTRLY_MISSPAYMENT_ADJUSTMENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"DISCOUNT_QTRLY_MISSPAYMENT_ADJUSTMENT\"\n	agenda-group \"AFTER_DISCOUNT\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,qtr > 1 ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  missedpayment == true  ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"RLI\", RLI );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"0\", bindings)) );\r\naction.execute( \"calc-discount\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL6afb50c:1724e644945:-6621', '\npackage rptbilling.PENALTY_QTRLY_MISSPAYMENT_ADJUSTMENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PENALTY_QTRLY_MISSPAYMENT_ADJUSTMENT\"\n	agenda-group \"AFTER_PENALTY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr > 1 ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  missedpayment == true  ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,revtype matches \"basic|sef\",TAX:amtdue,NMON:monthsfromjan ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"TAX\", TAX );\n		\n		bindings.put(\"NMON\", NMON );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * NMON * 0.02\", bindings)) );\r\naction.execute( \"calc-interest\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL6afb50c:1724e644945:-6b4e', '\npackage rptbilling.PENALTY_BASIC_SEF_CY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PENALTY_BASIC_SEF_CY\"\n	agenda-group \"PENALTY\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		 CurrentDate (  CY:year,CQTR:qtr > 1 ) \n		\n		RLI: rptis.landtax.facts.RPTLedgerItemFact (  year == CY,qtr < CQTR,TAX:amtdue,revtype matches \"basic|sef\",NMON:monthsfromjan ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"CY\", CY );\n		\n		bindings.put(\"CQTR\", CQTR );\n		\n		bindings.put(\"RLI\", RLI );\n		\n		bindings.put(\"TAX\", TAX );\n		\n		bindings.put(\"NMON\", NMON );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"rptledgeritem\", RLI );\r\n_p0.put( \"expr\", (new ActionExpression(\"TAX * NMON * 0.02\", bindings)) );\r\naction.execute( \"calc-interest\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL6d174068:14e3de9c20b:-7fcb', '\npackage miscassessment.CALC_RPU_ASSESSED_VALUE;\nimport miscassessment.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"CALC_RPU_ASSESSED_VALUE\"\n	agenda-group \"ASSESSEDVALUE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		MRPU: rptis.misc.facts.MiscRPU (  MV:marketvalue,AL:assesslevel ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"MRPU\", MRPU );\n		\n		bindings.put(\"MV\", MV );\n		\n		bindings.put(\"AL\", AL );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"miscrpu\", MRPU );\r\n_p0.put( \"expr\", (new ActionExpression(\"@ROUND( MV * AL / 100.0 ,2 )\", bindings)) );\r\naction.execute( \"calc-rpu-av\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-54ee', '\npackage rptbilling.PROV_SEF_SHARE_PREVIOUS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_SEF_SHARE_PREVIOUS\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_SEF_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_SEF_PREVIOUS_PROVINCE_SHARE\", \"RPT SEF PREVIOUS PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.50\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-5520', '\npackage rptbilling.PROV_SEF_SHARE_PREVIOUS_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_SEF_SHARE_PREVIOUS_PENALTY\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_SEFINT_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_SEFINT_PREVIOUS_PROVINCE_SHARE\", \"RPT SEF PENALTY PREVIOUS PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.50\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-5552', '\npackage rptbilling.PROV_SEF_SHARE_CURRENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_SEF_SHARE_CURRENT\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_SEF_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_SEF_CURRENT_PROVINCE_SHARE\", \"RPT SEF CURRENT PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.50\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-5584', '\npackage rptbilling.PROV_SEF_SHARE_CURRENT_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_SEF_SHARE_CURRENT_PENALTY\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_SEFINT_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_SEFINT_CURRENT_PROVINCE_SHARE\", \"RPT SEF PENALTY CURRENT PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.50\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-583b', '\npackage rptbilling.PROV_SEF_SHARE_ADVANCE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_SEF_SHARE_ADVANCE\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_SEF_ADVANCE\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_SEF_ADVANCE_PROVINCE_SHARE\", \"RPT SEF ADVANCE PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.50\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-588e', '\npackage rptbilling.PROV_BASIC_SHARE_ADVANCE;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_BASIC_SHARE_ADVANCE\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_ADVANCE\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_ADVANCE_PROVINCE_SHARE\", \"RPT BASIC ADVANCE PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.35\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-58d7', '\npackage rptbilling.PROV_BASIC_SHARE_CURRENT_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_BASIC_SHARE_CURRENT_PENALTY\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASICINT_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASICINT_CURRENT_PROVINCE_SHARE\", \"RPT BASIC PENALTY CURRENT PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.35\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-5939', '\npackage rptbilling.PROV_BASIC_SHARE_CURRENT;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_BASIC_SHARE_CURRENT\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_CURRENT\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_CURRENT_PROVINCE_SHARE\", \"RPT BASIC CURRENT PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.35\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-5972', '\npackage rptbilling.PROV_BASIC_SHARE_PREVIOUS_PENALTY;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_BASIC_SHARE_PREVIOUS_PENALTY\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASICINT_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASICINT_PREVIOUS_PROVINCE_SHARE\", \"RPT BASIC PENALTY PREVIOUS PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.35\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');
REPLACE INTO `sys_rule_deployed` (`objid`, `ruletext`) VALUES ('RUL713e35a1:1620963487c:-59d5', '\npackage rptbilling.PROV_BASIC_SHARE_PREVIOUS;\nimport rptbilling.*;\nimport java.util.*;\nimport com.rameses.rules.common.*;\n\nglobal RuleAction action;\n\nrule \"PROV_BASIC_SHARE_PREVIOUS\"\n	agenda-group \"LGU_SHARE\"\n	salience 50000\n	no-loop\n	when\n		\n		\n		BILLITEM: rptis.landtax.facts.RPTBillItem (  parentacctid matches \"RPT_BASIC_PREVIOUS\",AMOUNT:amount ) \n		\n		RL: rptis.landtax.facts.RPTLedgerFact (  PROVID:parentlguid ) \n		\n	then\n		Map bindings = new HashMap();\n		\n		bindings.put(\"BILLITEM\", BILLITEM );\n		\n		bindings.put(\"RL\", RL );\n		\n		bindings.put(\"AMOUNT\", AMOUNT );\n		\n		bindings.put(\"PROVID\", PROVID );\n		\n	Map _p0 = new HashMap();\r\n_p0.put( \"billitem\", BILLITEM );\r\n_p0.put( \"orgclass\", \"province\" );\r\n_p0.put( \"orgid\", PROVID );\r\n_p0.put( \"payableparentacct\", new KeyValue(\"RPT_BASIC_PREVIOUS_PROVINCE_SHARE\", \"RPT BASIC PREVIOUS PROVINCE SHARE\") );\r\n_p0.put( \"amtdue\", (new ActionExpression(\"AMOUNT\", bindings)) );\r\n_p0.put( \"rate\", (new ActionExpression(\"0.35\", bindings)) );\r\naction.execute( \"add-share\",_p0,drools);\r\n\nend\n\n\n	');

REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-16b3898d:15d15d43bd3:-55bb', 'rptincentive', 'Incentive', 'rptis.landtax.facts.RPTIncentive', '10', NULL, 'INCENTIVE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-245f3fbb:14f9b505a11:-7f93', 'TxnAttributeFact', 'TxnAttributeFact', 'TxnAttributeFact', '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-2486b0ca:146fff66c3e:-57b0', 'variable', 'Derived Variable', 'rptis.bldg.facts.BldgVariable', '35', NULL, 'VAR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-2486b0ca:146fff66c3e:-711c', 'BldgAdjustment', 'Building Adjustment', 'rptis.bldg.facts.BldgAdjustment', '10', NULL, 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-2486b0ca:146fff66c3e:-7ad1', 'BldgFloor', 'Building Floor', 'rptis.bldg.facts.BldgFloor', '4', NULL, 'BF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BldgUse', 'Building Actual Use', 'rptis.bldg.facts.BldgUse', '3', NULL, 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-2486b0ca:146fff66c3e:-7e0e', 'BldgStructure', 'Building Structure', 'rptis.bldg.facts.BldgStructure', '2', NULL, 'BS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-39192c48:1471ebc2797:-7faf', 'RPUAssessment', 'Assessment', 'rptis.facts.RPUAssessment', '80', NULL, 'RA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-5e76cf73:14d69e9c549:-7f07', 'LandAdjustment', 'Adjustment', 'rptis.land.facts.LandAdjustment', '6', NULL, 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-5ed6c5b0:16145892be0:-7d9c', 'AssessedValue', 'Assessed Value', 'rptis.landtax.facts.AssessedValue', '2', NULL, 'AVINFO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-66032c9:16155c11111:-7deb', 'Bill', 'Bill', 'rptis.landtax.facts.Bill', '2', NULL, 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-6d782e97:161e4c91fda:-3f40', 'Classification', 'Classification', 'rptis.landtax.facts.Classification', '0', NULL, 'CLASS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-78fba29f:161df51b937:-77bb', 'RPTBillItem', 'Bill Item', 'rptis.landtax.facts.RPTBillItem', '3', NULL, 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT-79a9a347:15cfcae84de:-3956', 'variable', 'Building Variable', 'rptis.bldg.facts.BldgVariable', '35', NULL, 'BLDGVAR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT1b4af871:14e3cc46e09:-34c1', 'miscvariable', 'System Variable', 'rptis.facts.RPTVariable', '1000', NULL, 'VAR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT1b4af871:14e3cc46e09:-36aa', 'MiscRPU', 'Miscellaneous RPU', 'rptis.misc.facts.MiscRPU', '0', NULL, 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT1be07afa:1452a9809e9:-731e', 'RPTLedgerTaxSummaryFact', 'Tax Summary', 'rptis.landtax.facts.RPTLedgerTaxSummaryFact', '21', NULL, 'RLTS', NULL, '', '', '', '', '', NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT1e772168:14c5a447e35:-7f78', 'MachineDetail', 'Machine', 'rptis.mach.facts.MachineDetail', '2', NULL, 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT1e772168:14c5a447e35:-7fd5', 'MachineActualUse', 'Actual Use', 'rptis.mach.facts.MachineActualUse', '3', NULL, 'MAU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT20ce1acc:141e456ed68:-7f43', 'CurrentDate', 'Current Date', 'CurrentDate', '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT357018a9:1452a5dcbf7:-793b', 'ShareFact', 'Share', 'rptis.landtax.facts.ShareFact', '50', NULL, 'LSH', NULL, '', '', '', '', '', NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT3afe51b9:146f7088d9c:-7db1', 'LandDetail', 'Appraisal', 'rptis.land.facts.LandDetail', '2', NULL, 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', 'RPU', 'rptis.facts.RPU', '-1', NULL, 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT3e2b89cb:146ff734573:-7fcb', 'BldgRPU', 'Building RPU', 'rptis.bldg.facts.BldgRPU', '1', NULL, 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'rpt', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT49ae4bad:141e3b6758c:-7ba3', 'currentdate', 'Current Date', 'CurrentDate', '1', '', '', NULL, '', '', '', '', '', '', 'LANDTAX', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT547c5381:1451ae1cd9c:-7933', 'rptledgeritem', 'Ledger Item', 'rptis.landtax.facts.RPTLedgerItemFact', '6', NULL, 'RLI', NULL, '', '', '', '', '', NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT547c5381:1451ae1cd9c:-798f', 'rptledger', 'Ledger', 'rptis.landtax.facts.RPTLedgerFact', '5', NULL, 'RL', '0', '', '', '', '', '', NULL, 'landtax', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT59614e16:14c5e56ecc8:-7fd1', 'MiscItem', 'Miscellaneous Item', 'rptis.misc.facts.MiscItem', '1', NULL, 'MI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT5b4ac915:147baaa06b4:-7146', 'classification', 'Classification', 'rptis.facts.Classification', '45', NULL, 'PC', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT64302071:14232ed987c:-7f4e', 'payoption', 'Pay Option', 'bpls.facts.PayOption', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT6b62feef:14c53ac1f59:-7f69', 'PlantTreeDetail', 'Plant/Tree Appraisal', 'rptis.planttree.facts.PlantTreeDetail', '1', NULL, 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT6d66cc31:1446cc9522e:-7ee1', 'RPTTxnInfoFact', 'RPTTxnInfoFact', 'RPTTxnInfoFact', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);
REPLACE INTO `sys_rule_fact` (`objid`, `name`, `title`, `factclass`, `sortorder`, `handler`, `defaultvarname`, `dynamic`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `dynamicfieldname`, `builtinconstraints`, `domain`, `factsuperclass`) VALUES ('RULFACT7ee0ab5e:141b6a15885:-7ff1', 'Ledger', 'Business Ledger', 'BPLedger', '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT', NULL);

REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-1306e459:14a228fb9ab:-233', 'RULFACT547c5381:1451ae1cd9c:-7933', 'qtrlypaymentavailed', 'Is Quarterly Payment?', 'boolean', '10', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-1306e459:14a228fb9ab:-37e', 'RULFACT547c5381:1451ae1cd9c:-7933', 'fullypaid', 'Is Fully Paid?', 'boolean', '9', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-16b3898d:15d15d43bd3:-557a', 'RULFACT-16b3898d:15d15d43bd3:-55bb', 'toyear', 'To Year', 'integer', '5', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-16b3898d:15d15d43bd3:-5583', 'RULFACT-16b3898d:15d15d43bd3:-55bb', 'fromyear', 'From Year', 'integer', '4', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-16b3898d:15d15d43bd3:-558c', 'RULFACT-16b3898d:15d15d43bd3:-55bb', 'sefrate', 'SEF Rate', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-16b3898d:15d15d43bd3:-5595', 'RULFACT-16b3898d:15d15d43bd3:-55bb', 'basicrate', 'Basic Rate', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-16b3898d:15d15d43bd3:-559f', 'RULFACT-16b3898d:15d15d43bd3:-55bb', 'rptledger', 'Ledger', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerFact', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-1be9605b:1561ac64a9e:-7ce0', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'depreciate', 'Depreciate?', 'boolean', '6', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-1be9605b:1561ac64a9e:-7d39', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'adjfordepreciation', 'Adjustment for Depreciation', 'decimal', '15', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2171899c:15e93ccd0af:-7aeb', 'RULFACT547c5381:1451ae1cd9c:-798f', 'objid', 'Objid', 'string', '1', 'lookup', 'rptledger:lookup', 'objid', 'tdno', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-23b1baca:15620373769:-7c10', 'RULFACT-39192c48:1471ebc2797:-7faf', 'exemptedmarketvalue', 'Exempted Market Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-245f3fbb:14f9b505a11:-7f76', 'RULFACT-245f3fbb:14f9b505a11:-7f93', 'attribute', 'Attribute', 'string', '2', 'lookup', 'faastxnattributetype:lookup', 'attribute', 'attribute', NULL, NULL, '1', 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-245f3fbb:14f9b505a11:-7f7f', 'RULFACT-245f3fbb:14f9b505a11:-7f93', 'txntype', 'Txn Type', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, '0', 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-5751', 'RULFACT-2486b0ca:146fff66c3e:-57b0', 'value', 'Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-5ee6', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'fixrate', 'Fix Rate Assess Level?', 'boolean', '26', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-70e6', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'amount', 'Amount', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-70f0', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'adjtype', 'Adjustment Type', 'string', '4', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BLDG_ADJUSTMENT_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7104', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'bldgfloor', 'Building Floor', 'string', '2', 'var', NULL, NULL, NULL, NULL, NULL, '1', 'rptis.bldg.facts.BldgFloor', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-78af', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'fixrate', 'Fix Rate Assess Level?', 'boolean', '11', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a4a', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'storeyrate', 'Storey Adjustment', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a55', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'marketvalue', 'Market Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a60', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'adjustment', 'Adjustment', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a6b', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'basemarketvalue', 'Base Market Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a76', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'unitvalue', 'Unit Value', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a81', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'basevalue', 'Base Value', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7a99', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'area', 'Area', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7aa6', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'bldguse', 'Building Actual Use', 'string', '2', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b08', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'assessedvalue', 'Assess Value', 'decimal', '10', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b11', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'assesslevel', 'Assess Level', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b1a', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'marketvalue', 'Market Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b23', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'adjustment', 'Adjustment', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b2c', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'depreciationvalue', 'Depreciation Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b35', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'basemarketvalue', 'Base Market Value', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b3e', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'area', 'Area', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b47', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'basevalue', 'Base Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7b50', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'bldgstructure', 'Building Structure', 'string', '2', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.bldg.facts.BldgStructure', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7db5', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'unitvalue', 'Unit Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7dbe', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'basevalue', 'Base Value', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7dc7', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'totalfloorarea', 'Total Floor Area', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7dd0', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'basefloorarea', 'Base Floor Area', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7dd9', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'floorcount', 'Floor Count', 'integer', '2', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-2486b0ca:146fff66c3e:-7dea', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'rpu', 'Building Real Property', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, '0', 'rptis.bldg.facts.BldgRPU', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-28dc975:156bcab666c:-6789', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'objid', 'objid', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-345b6aee:15625b107e8:-2d2d', 'RULFACT1e772168:14c5a447e35:-7fd5', 'taxable', 'Taxable', 'boolean', '5', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-39192c48:1471ebc2797:-7f3a', 'RULFACT-39192c48:1471ebc2797:-7faf', 'assessedvalue', 'Assessed Value', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-39192c48:1471ebc2797:-7f51', 'RULFACT-39192c48:1471ebc2797:-7faf', 'assesslevel', 'Assess Level', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-39192c48:1471ebc2797:-7f7e', 'RULFACT-39192c48:1471ebc2797:-7faf', 'marketvalue', 'Market Value', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-39192c48:1471ebc2797:-7f95', 'RULFACT-39192c48:1471ebc2797:-7faf', 'actualuseid', 'Actual Use', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, '1', 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-3ff2d28f:1508dea0692:-769e', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'objid', 'Objid', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-46fca07e:14c545f3e6a:-79a6', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'area', 'Area', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-495d2a02:146f0b98c4d:-7d21', 'RULFACT547c5381:1451ae1cd9c:-798f', 'lguid', 'LGU ID', 'string', '11', 'lookup', 'municipality:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-4a0d91d:16214600218:-7dff', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'cdurating', 'CDU Rating', 'string', '27', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'BLDG_CDU_RATING');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-533535f1:14ff7d1a0c7:2246', 'RULFACT6d66cc31:1446cc9522e:-7ee1', 'rputype', 'Property Type', 'string', '1', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_RPUTYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-533535f1:14ff7d1a0c7:226d', 'RULFACT6d66cc31:1446cc9522e:-7ee1', 'classificationid', 'Classification', 'string', '2', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-569e4b29:1452054ad68:-7a02', 'RULFACT547c5381:1451ae1cd9c:-798f', 'rputype', 'Property Type', 'string', '9', 'lov', '', '', '', '', NULL, NULL, 'string', 'RPT_RPUTYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-585c89e6:16156f39eeb:-7a07', 'RULFACT547c5381:1451ae1cd9c:-7933', 'qtrly', 'Is quarterly computed?', 'boolean', '20', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-590a6da0:14625d73c19:-4c60', 'RULFACT1be07afa:1452a9809e9:-731e', 'revperiod', 'Revenue Period', 'string', '3', 'lov', NULL, NULL, NULL, NULL, NULL, '0', 'string', 'RPT_REVENUE_PERIODS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5e76cf73:14d69e9c549:-7ec9', 'RULFACT-5e76cf73:14d69e9c549:-7f07', 'type', 'Adjustment Type', 'string', '4', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_LAND_ADJUSTMENT_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5e76cf73:14d69e9c549:-7ed2', 'RULFACT-5e76cf73:14d69e9c549:-7f07', 'adjustment', 'Adjustment', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5e76cf73:14d69e9c549:-7ee3', 'RULFACT-5e76cf73:14d69e9c549:-7f07', 'landdetail', 'Land Detail', 'string', '2', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5e76cf73:14d69e9c549:-7eec', 'RULFACT-5e76cf73:14d69e9c549:-7f07', 'rpu', 'RPU', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.facts.RPU', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7617', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'classification', 'Classification', 'string', '3', 'var', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'rptis.landtax.facts.Classification', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7d59', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'sefav', 'SEF Assessed Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7d62', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'basicav', 'Basic Assessed Value', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7d6b', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'av', 'Assessed Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, '1', 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7d74', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'year', 'Year', 'integer', '5', 'integer', NULL, NULL, NULL, NULL, NULL, '1', 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-5ed6c5b0:16145892be0:-7d7e', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'actualuse', 'Actual Use', 'string', '4', 'var', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, '0', 'rptis.landtax.facts.Classification', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-66032c9:16155c11111:-7db2', 'RULFACT-66032c9:16155c11111:-7deb', 'billtoqtr', 'Quarter', 'integer', '2', 'integer', NULL, NULL, NULL, NULL, NULL, '0', 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-66032c9:16155c11111:-7dca', 'RULFACT-66032c9:16155c11111:-7deb', 'billtoyear', 'Year', 'integer', '1', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-66ddf216:14f92338db7:-797f', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'useswornamount', 'Use Sworn Amount?', 'boolean', '14', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-66ddf216:14f92338db7:-798a', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'swornamount', 'Sworn Amount', 'decimal', '13', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-6c4ec747:154bd626092:-5677', 'RULFACT1e772168:14c5a447e35:-7f78', 'useswornamount', 'Is Sworn Amount?', 'boolean', '8', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-6c4ec747:154bd626092:-5693', 'RULFACT1e772168:14c5a447e35:-7f78', 'swornamount', 'Sworn Amount', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-6d782e97:161e4c91fda:-3f21', 'RULFACT-6d782e97:161e4c91fda:-3f40', 'objid', 'Classification', 'string', '1', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-71f47c05:161656ab29f:-7cd5', 'RULFACT1be07afa:1452a9809e9:-731e', 'revtype', 'Revenue Type', 'string', '2', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BILLING_REVENUE_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-72207dec:149d03afd0b:-6902', 'RULFACT547c5381:1451ae1cd9c:-7933', 'taxdifference', 'Is Tax Difference?', 'boolean', '11', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-7530836f:1508909e112:-7693', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'objid', 'Objid', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-42de', 'RULFACT547c5381:1451ae1cd9c:-798f', 'parentlguid', 'Parent LGU', 'string', '10', 'lookup', 'province:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-50ab', 'RULFACT547c5381:1451ae1cd9c:-798f', 'barangayid', 'Barangay ID', 'string', '12', 'lookup', 'barangay:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-76cb', 'RULFACT-78fba29f:161df51b937:-77bb', 'amount', 'Amount', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-76de', 'RULFACT-78fba29f:161df51b937:-77bb', 'sharetype', 'Share Type', 'string', '4', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BILLING_LGU_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-76e9', 'RULFACT-78fba29f:161df51b937:-77bb', 'revperiod', 'Revenue Period', 'string', '3', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_REVENUE_PERIODS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-778d', 'RULFACT-78fba29f:161df51b937:-77bb', 'revtype', 'Revenue Type', 'string', '2', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BILLING_REVENUE_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-78fba29f:161df51b937:-7797', 'RULFACT-78fba29f:161df51b937:-77bb', 'parentacctid', 'Account', 'string', '1', 'lookup', 'cashreceiptitem:lookup', 'objid', 'title', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-79a9a347:15cfcae84de:-3914', 'RULFACT-79a9a347:15cfcae84de:-3956', 'value', 'Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-79a9a347:15cfcae84de:-3925', 'RULFACT-79a9a347:15cfcae84de:-3956', 'varid', 'Variable Name', 'string', '2', 'lookup', 'rptparameter:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-79a9a347:15cfcae84de:-3937', 'RULFACT-79a9a347:15cfcae84de:-3956', 'bldguse', 'Building Actual Use', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-79a9a347:15cfcae84de:-754', 'RULFACT1e772168:14c5a447e35:-7f78', 'assesslevel', 'Assess Level', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-a35dd35:14e51ec3311:-608a', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'swornamount', 'Sworn Amount', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-a35dd35:14e51ec3311:-6104', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'useswornamount', 'Use Sworn Amount?', 'boolean', '4', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD-bc91bc6:14e8f2ce895:-7f59', 'RULFACT547c5381:1451ae1cd9c:-798f', 'undercompromise', 'Is under Compromise?', 'boolean', '6', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD102ab3e1:147190e9fe4:-56af', 'RULFACT-2486b0ca:146fff66c3e:-57b0', 'bldguse', 'Building Actual Use', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD102ab3e1:147190e9fe4:-66be', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'bldguse', 'Building Actual Use', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1441128c:1471efa4c1c:-6de2', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'actualuseid', 'Actual Use', 'string', '12', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1441128c:1471efa4c1c:-75ab', 'RULFACT-2486b0ca:146fff66c3e:-57b0', 'varid', 'Variable Name', 'string', '2', 'lookup', 'rptparameter:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD16890479:155dcd2ec4e:-7dd1', 'RULFACT1e772168:14c5a447e35:-7f78', 'taxable', 'Is Taxable', 'boolean', '7', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD17570bc8:16168d77d6c:-75cb', 'RULFACT357018a9:1452a5dcbf7:-793b', 'discount', 'Discount', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD17570bc8:16168d77d6c:-7760', 'RULFACT357018a9:1452a5dcbf7:-793b', 'revtype', 'Revenue Type', 'string', '3', 'lov', NULL, NULL, NULL, NULL, NULL, '1', 'string', 'RPT_BILLING_REVENUE_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD17570bc8:16168d77d6c:-78ef', 'RULFACT357018a9:1452a5dcbf7:-793b', 'amount', 'Amount', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD17570bc8:16168d77d6c:-7dfb', 'RULFACT1be07afa:1452a9809e9:-731e', 'ledger', 'Ledger', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerFact', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-3491', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'value', 'Value', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-34a2', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'varid', 'Variable Name', 'string', '3', 'lookup', 'rptparameter:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-34ab', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'refid', 'Reference ID', 'string', '2', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-3642', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'assessedvalue', 'Asessed Value', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-364b', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'assesslevel', 'Assess Level', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-3654', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'marketvalue', 'Market Value', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-365d', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'basemarketvalue', 'Base Market Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-366e', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'actualuseid', 'Actual Use', 'string', '3', 'lookup', 'propertyclassification:objid', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1b4af871:14e3cc46e09:-367f', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'classificationid', 'Classification', 'string', '2', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1be07afa:1452a9809e9:-332b', 'RULFACT357018a9:1452a5dcbf7:-793b', 'lgutype', 'LGU Type', 'string', '1', 'lov', '', '', '', '', NULL, '1', 'string', 'RPT_BILLING_LGU_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1be07afa:1452a9809e9:-45b2', 'RULFACT357018a9:1452a5dcbf7:-793b', 'revperiod', 'Revenue Period', 'string', '4', 'lov', '', '', '', '', NULL, '1', 'string', 'RPT_REVENUE_PERIODS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1be07afa:1452a9809e9:-72e6', 'RULFACT1be07afa:1452a9809e9:-731e', 'discount', 'Discount', 'decimal', '5', 'decimal', '', '', '', '', NULL, '0', 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1be07afa:1452a9809e9:-72ef', 'RULFACT1be07afa:1452a9809e9:-731e', 'interest', 'Interest', 'decimal', '6', 'decimal', '', '', '', '', NULL, '0', 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1be07afa:1452a9809e9:-72f8', 'RULFACT1be07afa:1452a9809e9:-731e', 'amount', 'Amount', 'decimal', '4', 'decimal', '', '', '', '', NULL, '0', 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1cb5fe2e:14cdb1a6034:-4308', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'additionalitemcode', 'Adjustment Code', 'string', '3', 'string', 'bldgadditionalitem:lookup', 'objid', 'name', NULL, NULL, '0', 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-662f', 'RULFACT1e772168:14c5a447e35:-7f78', 'depreciationvalue', 'Depreciation Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7f47', 'RULFACT1e772168:14c5a447e35:-7f78', 'assessedvalue', 'Assessed Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7f50', 'RULFACT1e772168:14c5a447e35:-7f78', 'marketvalue', 'Market Value', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7f59', 'RULFACT1e772168:14c5a447e35:-7f78', 'basemarketvalue', 'Base Market Value', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7f62', 'RULFACT1e772168:14c5a447e35:-7f78', 'machuse', 'Machine Actual Use', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.mach.facts.MachineActualUse', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7f98', 'RULFACT1e772168:14c5a447e35:-7fd5', 'assessedvalue', 'Assessed Value', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7fa3', 'RULFACT1e772168:14c5a447e35:-7fd5', 'marketvalue', 'Market Value', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7fae', 'RULFACT1e772168:14c5a447e35:-7fd5', 'basemarketvalue', 'Base Market Value', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD1e772168:14c5a447e35:-7fc1', 'RULFACT1e772168:14c5a447e35:-7fd5', 'actualuseid', 'Actual Use', 'string', '1', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD20ce1acc:141e456ed68:-7f35', 'RULFACT20ce1acc:141e456ed68:-7f43', 'month', 'Month', 'integer', '2', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD20ce1acc:141e456ed68:-7f3c', 'RULFACT20ce1acc:141e456ed68:-7f43', 'qtr', 'Qtr', 'integer', '1', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD29e16c33:156249fdf8e:-6e66', 'RULFACT-39192c48:1471ebc2797:-7faf', 'taxable', 'Taxable', 'boolean', '6', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD357018a9:1452a5dcbf7:-7765', 'RULFACT357018a9:1452a5dcbf7:-793b', 'sharetype', 'Share Type', 'string', '2', 'lov', '', '', '', '', NULL, '1', 'string', 'RPT_BILLING_SHARE_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d2b', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'assessedvalue', 'Assessed Value', 'decimal', '14', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d34', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'assesslevel', 'Assess Level', 'decimal', '13', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d3d', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'marketvalue', 'Market Value', 'decimal', '12', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d46', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'actualuseadjustment', 'Actual Use Adjustment', 'decimal', '11', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d4f', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'landvalueadjustment', 'Land Value Adjustment', 'decimal', '10', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d58', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'adjustment', 'Adjustment', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d61', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'basemarketvalue', 'Base Market Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d6a', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'taxable', 'Taxable', 'boolean', '7', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d73', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'unitvalue', 'Unit Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d7c', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'basevalue', 'Base Value', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d85', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'areaha', 'Area in Hectare', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d8e', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'areasqm', 'Area in Sq. Meter', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7d97', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'rpu', 'RPU', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'RPU', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7de0', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'useswornamount', 'Use Sworn Amount?', 'boolean', '12', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7dfb', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'swornamount', 'Sworn Amount', 'decimal', '13', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e0d', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'totalav', 'Assessed Value', 'decimal', '11', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e16', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'totalmv', 'Market Value', 'decimal', '10', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e1f', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'totalbmv', 'Base Market Value', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e28', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'totalareaha', 'Area in Hectare', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e31', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'totalareasqm', 'Area in Sq. Meter', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e3a', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'taxable', 'Taxable?', 'boolean', '6', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e4b', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'exemptiontypeid', 'Exemption Type', 'string', '5', 'lookup', 'exemptiontype:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e5c', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'classificationid', 'Classification', 'string', '4', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e65', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'ry', 'Revision Year', 'integer', '3', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3afe51b9:146f7088d9c:-7e92', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'rputype', 'Property Type', 'string', '2', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_RPUTYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e70', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'bldgclass', 'Building Class', 'string', '25', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BLDG_CLASS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e79', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'condominium', 'Is Condominium', 'boolean', '24', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e82', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'assesslevel', 'Assess Level', 'decimal', '23', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e8b', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'percentcompleted', 'Percent Completed', 'integer', '22', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e96', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totaladjustment', 'Total Adjustment', 'decimal', '21', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7e9f', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'depreciationvalue', 'Deprecation Value', 'decimal', '20', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ea8', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'depreciation', 'Depreciation Rate', 'decimal', '19', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7eb1', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'floorcount', 'Floor Count', 'integer', '18', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7eba', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'effectiveage', 'Effective Building Age', 'integer', '17', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ec3', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'bldgage', 'Building Age', 'integer', '16', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ecc', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'yroccupied', 'Year Occupied', 'integer', '15', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ed5', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'yrcompleted', 'Year Completed', 'integer', '14', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ede', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'yrappraised', 'Year Appraised', 'integer', '13', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ee7', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'basevalue', 'Base Value', 'decimal', '12', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7ef9', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'useswornamount', 'Use Sworn Amount?', 'boolean', '11', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f02', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'swornamount', 'Sworn Amount', 'decimal', '10', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f0b', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totalav', 'Assess Value', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f14', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totalmv', 'Market Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f1d', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totalbmv', 'Base Market Value', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f26', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totalareasqm', 'Area in Sq. Meter', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f2f', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'totalareaha', 'Area in Hectare', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f38', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'taxable', 'Taxable?', 'boolean', '4', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f49', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'exemptiontypeid', 'Exemption Type', 'string', '3', 'lookup', 'exemptiontype:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f5a', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'classificationid', 'Classification', 'string', '2', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', 'property');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD3e2b89cb:146ff734573:-7f63', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'ry', 'Revision Year', 'integer', '1', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49a3c540:14e51feb8f6:-5a4c', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'objid', 'Objid', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49a3c540:14e51feb8f6:-6cc5', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'objid', 'RPU ID', 'string', '1', 'string', NULL, NULL, NULL, NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49ae4bad:141e3b6758c:-7b87', 'RULFACT49ae4bad:141e3b6758c:-7ba3', 'day', 'Day', 'integer', '4', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49ae4bad:141e3b6758c:-7b8e', 'RULFACT49ae4bad:141e3b6758c:-7ba3', 'month', 'Month', 'integer', '3', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49ae4bad:141e3b6758c:-7b95', 'RULFACT49ae4bad:141e3b6758c:-7ba3', 'qtr', 'Quarter', 'integer', '2', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD49ae4bad:141e3b6758c:-7b9c', 'RULFACT49ae4bad:141e3b6758c:-7ba3', 'year', 'Year', 'integer', '1', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD4bf973aa:1562a233196:-4e2d', 'RULFACT1e772168:14c5a447e35:-7f78', 'depreciation', 'Depreciation Rate', 'boolean', '10', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7704', 'RULFACT547c5381:1451ae1cd9c:-798f', 'barangay', 'Barangay', 'string', '8', 'lookup', 'barangay:lookup', 'objid', 'name', '', NULL, NULL, 'string', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7798', 'RULFACT547c5381:1451ae1cd9c:-7933', 'interest', 'Interest', 'decimal', '18', 'decimal', '', '', '', '', NULL, NULL, 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-77a1', 'RULFACT547c5381:1451ae1cd9c:-7933', 'amtdue', 'Tax', 'decimal', '17', 'decimal', '', '', '', '', NULL, NULL, 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7867', 'RULFACT547c5381:1451ae1cd9c:-7933', 'reclassed', 'Is Reclassed?', 'boolean', '7', 'boolean', '', '', '', '', NULL, NULL, 'boolean', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7870', 'RULFACT547c5381:1451ae1cd9c:-7933', 'revperiod', 'Revenue Period', 'string', '16', 'lov', '', '', '', '', NULL, NULL, 'string', 'RPT_REVENUE_PERIODS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-789d', 'RULFACT547c5381:1451ae1cd9c:-7933', 'backtax', 'Is Back Tax?', 'boolean', '14', 'boolean', '', '', '', '', NULL, NULL, 'boolean', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78a6', 'RULFACT547c5381:1451ae1cd9c:-7933', 'monthsfromjan', 'Number of Months from January', 'integer', '13', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78af', 'RULFACT547c5381:1451ae1cd9c:-7933', 'monthsfromqtr', 'Number of Months From Quarter', 'integer', '12', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78e0', 'RULFACT547c5381:1451ae1cd9c:-7933', 'actualuse', 'Actual Use', 'string', '6', 'lookup', 'propertyclassification:lookup', 'objid', 'title', '', NULL, NULL, 'string', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78e9', 'RULFACT547c5381:1451ae1cd9c:-7933', 'classification', 'Classification', 'string', '5', 'lookup', 'propertyclassification:lookup', 'objid', 'name', '', '0', NULL, 'string', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78f2', 'RULFACT547c5381:1451ae1cd9c:-7933', 'txntype', 'Txn Type', 'string', '4', 'lov', '', '', '', '', NULL, NULL, 'string', 'RPT_TXN_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-78fb', 'RULFACT547c5381:1451ae1cd9c:-7933', 'av', 'Assessed Value', 'decimal', '3', 'decimal', '', '', '', '', NULL, NULL, 'decimal', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-790d', 'RULFACT547c5381:1451ae1cd9c:-7933', 'qtr', 'Qtr', 'integer', '2', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7916', 'RULFACT547c5381:1451ae1cd9c:-7933', 'year', 'Year', 'integer', '1', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-795c', 'RULFACT547c5381:1451ae1cd9c:-798f', 'qtrlypaymentpaidontime', 'Quarterly Payment is Paid On-Time', 'boolean', '5', 'boolean', '', '', '', '', NULL, NULL, 'boolean', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7965', 'RULFACT547c5381:1451ae1cd9c:-798f', 'firstqtrpaidontime', '1st Qtr is Paid On-Time', 'boolean', '4', 'boolean', '', '', '', '', NULL, NULL, 'boolean', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-7970', 'RULFACT547c5381:1451ae1cd9c:-798f', 'lastqtrpaid', 'Last Qtr Paid', 'integer', '3', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD547c5381:1451ae1cd9c:-797b', 'RULFACT547c5381:1451ae1cd9c:-798f', 'lastyearpaid', 'Last Year Paid', 'integer', '2', 'integer', '', '', '', '', NULL, NULL, 'integer', '');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7ea9', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'depreciation', 'Deprecation Rate', 'decimal', '2', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7f8f', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'assessedvalue', 'Assessed Value', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7f9a', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'assesslevel', 'Assess Level', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7fa5', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'marketvalue', 'Market Value', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7fb0', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'depreciatedvalue', 'Depreciation', 'decimal', '3', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD59614e16:14c5e56ecc8:-7fbb', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'basemarketvalue', 'Base Market Value', 'decimal', '1', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD5b4ac915:147baaa06b4:-6e01', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'classification', 'Classification', 'string', '15', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'rptis.facts.Classification', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD5b4ac915:147baaa06b4:-7111', 'RULFACT5b4ac915:147baaa06b4:-7146', 'objid', 'Classification', 'string', '1', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD5d750d7e:161889cc785:-7702', 'RULFACT-66032c9:16155c11111:-7deb', 'currentdate', 'Current Date', 'date', '3', 'date', NULL, NULL, NULL, NULL, NULL, NULL, 'date', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD600de0dd:14891e3a85f:-7851', 'RULFACT547c5381:1451ae1cd9c:-7933', 'discount', 'Discount', 'decimal', '19', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD600de0dd:14891e3a85f:-7f9d', 'RULFACT547c5381:1451ae1cd9c:-7933', 'idleland', 'Is Idle Land?', 'boolean', '8', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD603bde10:15e028ba480:-7d9f', 'RULFACT547c5381:1451ae1cd9c:-798f', 'missedpayment', 'Has missed current year Quarterly Payment?', 'boolean', '7', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD634d9a3c:161503ff1dc:-529e', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'txntype', 'Transaction Type', 'string', '2', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_TXN_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD634d9a3c:161503ff1dc:-531f', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'rputype', 'Property Type', 'string', '1', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_RPUTYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD634d9a3c:161503ff1dc:-7628', 'RULFACT547c5381:1451ae1cd9c:-7933', 'revtype', 'Revenue Type', 'string', '15', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_BILLING_REVENUE_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD64302071:14232ed987c:-7f3d', 'RULFACT64302071:14232ed987c:-7f4e', 'type', 'Type', 'string', '1', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'BP_PAYOPTIONS');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ec5', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'assessedvalue', 'Assessed Value', 'decimal', '13', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ece', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'assesslevel', 'Assess Level', 'decimal', '12', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ed7', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'marketvalue', 'Market Value', 'decimal', '11', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ee0', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'adjustmentrate', 'Adjustment Rate', 'decimal', '10', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ee9', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'adjustment', 'Adjustment', 'decimal', '9', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7ef2', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'basemarketvalue', 'Base Market Value', 'decimal', '8', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7efb', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'unitvalue', 'Unit Value', 'decimal', '7', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f04', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'areacovered', 'Area Covered', 'decimal', '6', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f0d', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'nonproductive', 'Non-Productive', 'decimal', '5', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f16', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'productive', 'Productive', 'decimal', '4', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f39', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'classificationid', 'Classification', 'string', '2', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f4a', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'actualuseid', 'Actual Use', 'string', '3', 'lookup', 'propertyclassification:lookup', 'objid', 'name', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6b62feef:14c53ac1f59:-7f53', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'RPU', 'RPU', 'string', '1', 'var', NULL, NULL, NULL, NULL, NULL, NULL, 'RPU', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6d66cc31:1446cc9522e:-7e84', 'RULFACT6d66cc31:1446cc9522e:-7ee1', 'planRequired', 'Approved Plan Required', 'boolean', '3', 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, 'boolean', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6d66cc31:1446cc9522e:-7ea0', 'RULFACT6d66cc31:1446cc9522e:-7ee1', 'txntypemode', 'Txn Type Mode', 'string', '2', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, 'string', 'RPT_TXN_TYPE_MODES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD6d66cc31:1446cc9522e:-7ebd', 'RULFACT6d66cc31:1446cc9522e:-7ee1', 'txntype', 'Txn Type', 'string', '3', 'lov', NULL, NULL, NULL, NULL, NULL, '1', 'string', 'RPT_TXN_TYPES');
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD7ee0ab5e:141b6a15885:-7fd5', 'RULFACT7ee0ab5e:141b6a15885:-7ff1', 'amtdue', 'Amount Due', 'decimal', '1', 'decimal', NULL, NULL, NULL, NULL, NULL, NULL, 'decimal', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD7ee0ab5e:141b6a15885:-7fdc', 'RULFACT7ee0ab5e:141b6a15885:-7ff1', 'qtr', 'Qtr', 'integer', '2', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD7ee0ab5e:141b6a15885:-7fe3', 'RULFACT7ee0ab5e:141b6a15885:-7ff1', 'year', 'Year', 'integer', '3', 'integer', NULL, NULL, NULL, NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_fact_field` (`objid`, `parentid`, `name`, `title`, `datatype`, `sortorder`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `lookupdatatype`, `multivalued`, `required`, `vardatatype`, `lovname`) VALUES ('FACTFLD7ee0ab5e:141b6a15885:-7fea', 'RULFACT7ee0ab5e:141b6a15885:-7ff1', 'apptype', 'Application Type', NULL, '4', 'lov', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'BUSINESS_APP_TYPES');

REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'LandDetail', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'LA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f0c', 'RUL713e35a1:1620963487c:-54ee', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f0f', 'RUL713e35a1:1620963487c:-54ee', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f19', 'RUL713e35a1:1620963487c:-5520', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f1b', 'RUL713e35a1:1620963487c:-5520', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f28', 'RUL713e35a1:1620963487c:-5552', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f2a', 'RUL713e35a1:1620963487c:-5552', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f33', 'RUL713e35a1:1620963487c:-5584', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f36', 'RUL713e35a1:1620963487c:-5584', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f48', 'RUL713e35a1:1620963487c:-583b', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f4b', 'RUL713e35a1:1620963487c:-583b', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f58', 'RUL713e35a1:1620963487c:-588e', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f5a', 'RUL713e35a1:1620963487c:-588e', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f64', 'RUL713e35a1:1620963487c:-58d7', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f66', 'RUL713e35a1:1620963487c:-58d7', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f6f', 'RUL713e35a1:1620963487c:-5939', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f72', 'RUL713e35a1:1620963487c:-5939', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f7b', 'RUL713e35a1:1620963487c:-5972', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f7e', 'RUL713e35a1:1620963487c:-5972', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f8b', 'RUL713e35a1:1620963487c:-59d5', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-293918d4:16209768e19:-7f8d', 'RUL713e35a1:1620963487c:-59d5', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-69b5f604:15cfc6b3e74:-7e3b', 'RUL-79a9a347:15cfcae84de:-707b', 'BldgAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'BA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7edf', 'RUL5d750d7e:161889cc785:-5f54', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7ee2', 'RUL5d750d7e:161889cc785:-5f54', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7ee5', 'RUL5d750d7e:161889cc785:-5f54', 'Bill', 'RULFACT-66032c9:16155c11111:-7deb', 'BILL', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7f0b', 'RUL5d750d7e:161889cc785:-61f2', 'Bill', 'RULFACT-66032c9:16155c11111:-7deb', 'BILL', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7f0e', 'RUL5d750d7e:161889cc785:-61f2', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7f11', 'RUL5d750d7e:161889cc785:-61f2', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC-6bcddeab:16188c09983:-7fd7', 'RUL5d750d7e:161889cc785:-72c0', 'Bill', 'RULFACT-66032c9:16155c11111:-7deb', 'BILL', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13423d65:162270a87db:-7c69', 'RUL-621d5f20:16222e9bf6d:-bc0', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13423d65:162270a87db:-7c6d', 'RUL-621d5f20:16222e9bf6d:-bc0', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13423d65:162270a87db:-7cd0', 'RUL-621d5f20:16222e9bf6d:-19d5', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13423d65:162270a87db:-7cd6', 'RUL-621d5f20:16222e9bf6d:-19d5', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13524a8b:161b645b0bf:-7fe0', 'RUL-7deff7e5:161b60a3048:-5a7e', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC13524a8b:161b645b0bf:-7fe2', 'RUL-7deff7e5:161b60a3048:-5a7e', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC16a7ee38:15cfcd300fe:-7fba', 'RUL-79a9a347:15cfcae84de:-55fd', 'RPUAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'RA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC16a7ee38:15cfcd300fe:-7fbc', 'RUL-79a9a347:15cfcae84de:-55fd', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fba', 'RUL-78fba29f:161df51b937:-4837', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fbc', 'RUL-78fba29f:161df51b937:-4837', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fc6', 'RUL-78fba29f:161df51b937:-4951', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fc8', 'RUL-78fba29f:161df51b937:-4951', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fd1', 'RUL-78fba29f:161df51b937:-4a59', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fd4', 'RUL-78fba29f:161df51b937:-4a59', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fe3', 'RUL-78fba29f:161df51b937:-4b72', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7fe6', 'RUL-78fba29f:161df51b937:-4b72', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7ff0', 'RUL-78fba29f:161df51b937:-4bf1', 'RPTBillItem', 'RULFACT-78fba29f:161df51b937:-77bb', 'BILLITEM', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC42bdb818:161e073d7b8:-7ff2', 'RUL-78fba29f:161df51b937:-4bf1', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC67caf065:1724e308e34:-7336', 'RUL6afb50c:1724e644945:-6621', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC67caf065:1724e308e34:-7338', 'RUL6afb50c:1724e644945:-6621', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC67caf065:1724e308e34:-733b', 'RUL6afb50c:1724e644945:-6621', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC67caf065:1724e308e34:-7385', 'RUL6afb50c:1724e644945:-6b4e', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RC67caf065:1724e308e34:-738e', 'RUL6afb50c:1724e644945:-6b4e', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-103fed47:146ffb40356:-7d40', 'RUL3e2b89cb:146ff734573:-7dcc', 'BldgRPU', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-13574fd2:1621b509f0b:-71e5', 'RUL-2486b0ca:146fff66c3e:-4697', 'BldgRPU', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-2bf1', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3888', 'RUL-2486b0ca:146fff66c3e:-38e4', 'BldgFloor', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'BF', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3ed1', 'RUL-2486b0ca:146fff66c3e:-4192', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3f91', 'RUL-2486b0ca:146fff66c3e:-4192', 'BldgRPU', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-445d', 'RUL-2486b0ca:146fff66c3e:-4697', 'BldgStructure', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'BS', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-2486b0ca:146fff66c3e:-6aad', 'RUL-2486b0ca:146fff66c3e:-6b05', 'BldgFloor', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'BF', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-28dc975:156bcab666c:-5f3d', 'RUL-3e8edbea:156bc08656a:-5f05', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-28dc975:156bcab666c:-6051', 'RUL-3e8edbea:156bc08656a:-5f05', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-46fca07e:14c545f3e6a:-3353', 'RUL-46fca07e:14c545f3e6a:-33b4', 'BldgFloor', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'BF', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-46fca07e:14c545f3e6a:-34b0', 'RUL-46fca07e:14c545f3e6a:-350f', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-46fca07e:14c545f3e6a:-7707', 'RUL-46fca07e:14c545f3e6a:-7740', 'LandDetail', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'LA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-46fca07e:14c545f3e6a:-786f', 'RUL-46fca07e:14c545f3e6a:-7a8b', 'LandDetail', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'LA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-585c89e6:16156f39eeb:-7586', 'RUL-585c89e6:16156f39eeb:-770f', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-585c89e6:16156f39eeb:-760c', 'RUL-585c89e6:16156f39eeb:-770f', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-59249a93:1614f57bd58:-7d29', 'RUL-59249a93:1614f57bd58:-7d49', 'AssessedValue', 'RULFACT-5ed6c5b0:16145892be0:-7d9c', 'AVINFO', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-5e76cf73:14d69e9c549:-701c', 'RUL-5e76cf73:14d69e9c549:-7084', 'LandDetail', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'LA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-5e76cf73:14d69e9c549:-7e5d', 'RUL-5e76cf73:14d69e9c549:-7fd4', 'LandAdjustment', 'RULFACT-5e76cf73:14d69e9c549:-7f07', 'ADJ', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-60c99d04:1470b276e7f:-7dd3', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-60c99d04:1470b276e7f:-7e2a', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BldgStructure', 'RULFACT-2486b0ca:146fff66c3e:-7e0e', 'BS', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-6c4ec747:154bd626092:-55c3', 'RUL-6c4ec747:154bd626092:-5616', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-762e9176:15d067a9c42:-5928', 'RUL-762e9176:15d067a9c42:-5aa0', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-762e9176:15d067a9c42:-5a4b', 'RUL-762e9176:15d067a9c42:-5aa0', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-762e9176:15d067a9c42:-5d56', 'RUL-762e9176:15d067a9c42:-5e26', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-762e9176:15d067a9c42:-5dd2', 'RUL-762e9176:15d067a9c42:-5e26', 'RPUAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'RA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-78fba29f:161df51b937:-7478', 'RUL-78fba29f:161df51b937:-74da', 'RPTLedgerTaxSummaryFact', 'RULFACT1be07afa:1452a9809e9:-731e', 'RLTS', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-1e48', 'RUL-79a9a347:15cfcae84de:-1ed3', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-1e8b', 'RUL-79a9a347:15cfcae84de:-1ed3', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-20e8', 'RUL-79a9a347:15cfcae84de:-2167', 'RPUAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'RA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-5af4', 'RUL-79a9a347:15cfcae84de:-6f2a', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-6222', 'RUL-79a9a347:15cfcae84de:-6401', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-637a', 'RUL-79a9a347:15cfcae84de:-6401', 'RPUAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'RA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-6ebc', 'RUL-79a9a347:15cfcae84de:-6f2a', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-928', 'RUL-79a9a347:15cfcae84de:-b33', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-a77', 'RUL-79a9a347:15cfcae84de:-b33', 'MachineActualUse', 'RULFACT1e772168:14c5a447e35:-7fd5', 'MAU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:-c6d', 'RUL-79a9a347:15cfcae84de:-2167', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:4fcd', 'RUL-79a9a347:15cfcae84de:4f83', 'RPUAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'RA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:508d', 'RUL-79a9a347:15cfcae84de:4f83', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:553c', 'RUL-79a9a347:15cfcae84de:549e', 'RPU', 'RULFACT3afe51b9:146f7088d9c:-7eb6', 'RPU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:55ab', 'RUL-79a9a347:15cfcae84de:549e', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-79a9a347:15cfcae84de:fb4', 'RUL-79a9a347:15cfcae84de:f6c', 'PlantTreeDetail', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'PTD', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND-a35dd35:14e51ec3311:-5d14', 'RUL-a35dd35:14e51ec3311:-5d4c', 'MiscRPU', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'MRPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1441128c:1471efa4c1c:-6c2f', 'RUL1441128c:1471efa4c1c:-6c93', 'BldgAssessment', 'RULFACT-39192c48:1471ebc2797:-7faf', 'BA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1441128c:1471efa4c1c:-6d84', 'RUL1441128c:1471efa4c1c:-6eaa', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1b4af871:14e3cc46e09:-2fc5', 'RUL1b4af871:14e3cc46e09:-301e', 'MiscItem', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'MI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1b4af871:14e3cc46e09:-2fe8', 'RUL1b4af871:14e3cc46e09:-301e', 'MiscRPU', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'MRPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1b4af871:14e3cc46e09:-31fc', 'RUL1b4af871:14e3cc46e09:-3341', 'MiscItem', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'MI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1b4af871:14e3cc46e09:-3242', 'RUL1b4af871:14e3cc46e09:-3341', 'MiscRPU', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'MRPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e772168:14c5a447e35:-65bc', 'RUL1e772168:14c5a447e35:-669c', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e772168:14c5a447e35:-6cfc', 'RUL1e772168:14c5a447e35:-6d2f', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e772168:14c5a447e35:-7dce', 'RUL1e772168:14c5a447e35:-7e01', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:2ff', 'RUL1e983c10:147f2149816:2bc', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:373', 'RUL1e983c10:147f2149816:2bc', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:479', 'RUL1e983c10:147f2149816:437', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:4df', 'RUL1e983c10:147f2149816:437', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:60f', 'RUL1e983c10:147f2149816:5a3', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1e983c10:147f2149816:675', 'RUL1e983c10:147f2149816:5a3', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND1ff29cd0:1572617f8d8:-7d30', 'RUL-a35dd35:14e51ec3311:-5d4c', 'MiscItem', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'MI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND37df8403:14c5405fff0:-7693', 'RUL37df8403:14c5405fff0:-76bf', 'PlantTreeDetail', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'PTD', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3b800abe:14d2b978f55:-6196', 'RUL3b800abe:14d2b978f55:-61fb', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3b800abe:14d2b978f55:-6339', 'RUL3b800abe:14d2b978f55:-63a0', 'BldgFloor', 'RULFACT-2486b0ca:146fff66c3e:-7ad1', 'BF', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3b800abe:14d2b978f55:-7d69', 'RUL3b800abe:14d2b978f55:-7e09', 'BldgAdjustment', 'RULFACT-2486b0ca:146fff66c3e:-711c', 'ADJ', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3de2e0bf:15165926561:-7b18', 'RUL3de2e0bf:15165926561:-7bfc', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3de2e0bf:15165926561:-7bb4', 'RUL3de2e0bf:15165926561:-7bfc', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND3fb43b91:14ccf782188:-5fd2', 'RUL3fb43b91:14ccf782188:-6008', 'PlantTreeDetail', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'PTD', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND49a3c540:14e51feb8f6:-76da', 'RUL49a3c540:14e51feb8f6:-77d2', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR2', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND49a3c540:14e51feb8f6:-774e', 'RUL49a3c540:14e51feb8f6:-77d2', 'miscvariable', 'RULFACT1b4af871:14e3cc46e09:-34c1', 'VAR1', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND49a3c540:14e51feb8f6:-779a', 'RUL49a3c540:14e51feb8f6:-77d2', 'MiscRPU', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'MRPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND4bf973aa:1562a233196:-500e', 'RUL4bf973aa:1562a233196:-5055', 'MachineDetail', 'RULFACT1e772168:14c5a447e35:-7f78', 'MACH', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND4e46261d:14f924c6b53:-7c57', 'RUL4e46261d:14f924c6b53:-7d9b', 'BldgUse', 'RULFACT-2486b0ca:146fff66c3e:-7b6a', 'BU', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND4e46261d:14f924c6b53:-7d37', 'RUL4e46261d:14f924c6b53:-7d9b', 'BldgRPU', 'RULFACT3e2b89cb:146ff734573:-7fcb', 'RPU', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND4fc9c2c7:176cac860ed:-75f6', 'RUL4fc9c2c7:176cac860ed:-76d7', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND4fc9c2c7:176cac860ed:-768b', 'RUL4fc9c2c7:176cac860ed:-76d7', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5022d8ba:1589ae965a4:-7c5c', 'RUL5022d8ba:1589ae965a4:-7c9c', 'PlantTreeDetail', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'PTD', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND59614e16:14c5e56ecc8:-7c8f', 'RUL59614e16:14c5e56ecc8:-7cbf', 'MiscItem', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'MI', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND59614e16:14c5e56ecc8:-7dcb', 'RUL59614e16:14c5e56ecc8:-7dfb', 'MiscItem', 'RULFACT59614e16:14c5e56ecc8:-7fd1', 'MI', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5a030c2b:17277b1ddc5:-7e0f', 'RUL5a030c2b:17277b1ddc5:-7e65', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5b4ac915:147baaa06b4:-6da4', 'RUL5b4ac915:147baaa06b4:-6f31', 'LandDetail', 'RULFACT3afe51b9:146f7088d9c:-7db1', 'LA', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5b84d618:1615428187f:-622b', 'RUL5b84d618:1615428187f:-62e3', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5b84d618:1615428187f:-62a3', 'RUL5b84d618:1615428187f:-62e3', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5b84d618:1615428187f:-66fa', 'RUL5b84d618:1615428187f:-67ce', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5b84d618:1615428187f:-677a', 'RUL5b84d618:1615428187f:-67ce', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5d750d7e:161889cc785:-6f08', 'RUL5d750d7e:161889cc785:-7301', 'Bill', 'RULFACT-66032c9:16155c11111:-7deb', 'BILL', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5d750d7e:161889cc785:-7066', 'RUL5d750d7e:161889cc785:-7301', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND5d750d7e:161889cc785:-713b', 'RUL5d750d7e:161889cc785:-7301', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND634d9a3c:161503ff1dc:-586c', 'RUL634d9a3c:161503ff1dc:-5b2a', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND650f832b:14c53e6ce93:-79a1', 'RUL650f832b:14c53e6ce93:-79cd', 'PlantTreeDetail', 'RULFACT6b62feef:14c53ac1f59:-7f69', 'PTD', '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6afb50c:1724e644945:-5f45', 'RUL6afb50c:1724e644945:-602d', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6afb50c:1724e644945:-5fea', 'RUL6afb50c:1724e644945:-602d', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6afb50c:1724e644945:-6144', 'RUL6afb50c:1724e644945:-62f2', 'rptledgeritem', 'RULFACT547c5381:1451ae1cd9c:-7933', 'RLI', '2', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6afb50c:1724e644945:-61d4', 'RUL6afb50c:1724e644945:-62f2', 'rptledger', 'RULFACT547c5381:1451ae1cd9c:-798f', 'RL', '1', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6afb50c:1724e644945:-62a7', 'RUL6afb50c:1724e644945:-62f2', 'currentdate', 'RULFACT49ae4bad:141e3b6758c:-7ba3', NULL, '0', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition` (`objid`, `parentid`, `fact_name`, `fact_objid`, `varname`, `pos`, `ruletext`, `displaytext`, `dynamic_datatype`, `dynamic_key`, `dynamic_value`, `notexist`) VALUES ('RCOND6d174068:14e3de9c20b:-7f93', 'RUL6d174068:14e3de9c20b:-7fcb', 'MiscRPU', 'RULFACT1b4af871:14e3cc46e09:-36aa', 'MRPU', '0', NULL, NULL, NULL, NULL, NULL, '0');

REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'LA', 'rptis.land.facts.LandDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f0c', 'RC-293918d4:16209768e19:-7f0c', 'RUL713e35a1:1620963487c:-54ee', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f0f', 'RC-293918d4:16209768e19:-7f0f', 'RUL713e35a1:1620963487c:-54ee', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f19', 'RC-293918d4:16209768e19:-7f19', 'RUL713e35a1:1620963487c:-5520', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f1b', 'RC-293918d4:16209768e19:-7f1b', 'RUL713e35a1:1620963487c:-5520', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f28', 'RC-293918d4:16209768e19:-7f28', 'RUL713e35a1:1620963487c:-5552', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f2a', 'RC-293918d4:16209768e19:-7f2a', 'RUL713e35a1:1620963487c:-5552', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f33', 'RC-293918d4:16209768e19:-7f33', 'RUL713e35a1:1620963487c:-5584', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f36', 'RC-293918d4:16209768e19:-7f36', 'RUL713e35a1:1620963487c:-5584', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f48', 'RC-293918d4:16209768e19:-7f48', 'RUL713e35a1:1620963487c:-583b', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f4b', 'RC-293918d4:16209768e19:-7f4b', 'RUL713e35a1:1620963487c:-583b', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f58', 'RC-293918d4:16209768e19:-7f58', 'RUL713e35a1:1620963487c:-588e', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f5a', 'RC-293918d4:16209768e19:-7f5a', 'RUL713e35a1:1620963487c:-588e', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f64', 'RC-293918d4:16209768e19:-7f64', 'RUL713e35a1:1620963487c:-58d7', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f66', 'RC-293918d4:16209768e19:-7f66', 'RUL713e35a1:1620963487c:-58d7', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f6f', 'RC-293918d4:16209768e19:-7f6f', 'RUL713e35a1:1620963487c:-5939', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f72', 'RC-293918d4:16209768e19:-7f72', 'RUL713e35a1:1620963487c:-5939', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f7b', 'RC-293918d4:16209768e19:-7f7b', 'RUL713e35a1:1620963487c:-5972', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f7e', 'RC-293918d4:16209768e19:-7f7e', 'RUL713e35a1:1620963487c:-5972', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f8b', 'RC-293918d4:16209768e19:-7f8b', 'RUL713e35a1:1620963487c:-59d5', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-293918d4:16209768e19:-7f8d', 'RC-293918d4:16209768e19:-7f8d', 'RUL713e35a1:1620963487c:-59d5', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-69b5f604:15cfc6b3e74:-7e3b', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'RUL-79a9a347:15cfcae84de:-707b', 'BA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-6bcddeab:16188c09983:-7ee2', 'RC-6bcddeab:16188c09983:-7ee2', 'RUL5d750d7e:161889cc785:-5f54', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-6bcddeab:16188c09983:-7ee5', 'RC-6bcddeab:16188c09983:-7ee5', 'RUL5d750d7e:161889cc785:-5f54', 'BILL', 'rptis.landtax.facts.Bill', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-6bcddeab:16188c09983:-7f0b', 'RC-6bcddeab:16188c09983:-7f0b', 'RUL5d750d7e:161889cc785:-61f2', 'BILL', 'rptis.landtax.facts.Bill', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-6bcddeab:16188c09983:-7f0e', 'RC-6bcddeab:16188c09983:-7f0e', 'RUL5d750d7e:161889cc785:-61f2', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC-6bcddeab:16188c09983:-7fd7', 'RC-6bcddeab:16188c09983:-7fd7', 'RUL5d750d7e:161889cc785:-72c0', 'BILL', 'rptis.landtax.facts.Bill', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC13423d65:162270a87db:-7c6d', 'RC13423d65:162270a87db:-7c6d', 'RUL-621d5f20:16222e9bf6d:-bc0', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC13423d65:162270a87db:-7cd6', 'RC13423d65:162270a87db:-7cd6', 'RUL-621d5f20:16222e9bf6d:-19d5', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC13524a8b:161b645b0bf:-7fe0', 'RC13524a8b:161b645b0bf:-7fe0', 'RUL-7deff7e5:161b60a3048:-5a7e', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC16a7ee38:15cfcd300fe:-7fba', 'RC16a7ee38:15cfcd300fe:-7fba', 'RUL-79a9a347:15cfcae84de:-55fd', 'RA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC16a7ee38:15cfcd300fe:-7fbc', 'RC16a7ee38:15cfcd300fe:-7fbc', 'RUL-79a9a347:15cfcae84de:-55fd', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fba', 'RC42bdb818:161e073d7b8:-7fba', 'RUL-78fba29f:161df51b937:-4837', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fbc', 'RC42bdb818:161e073d7b8:-7fbc', 'RUL-78fba29f:161df51b937:-4837', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fc6', 'RC42bdb818:161e073d7b8:-7fc6', 'RUL-78fba29f:161df51b937:-4951', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fc8', 'RC42bdb818:161e073d7b8:-7fc8', 'RUL-78fba29f:161df51b937:-4951', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fd1', 'RC42bdb818:161e073d7b8:-7fd1', 'RUL-78fba29f:161df51b937:-4a59', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fd4', 'RC42bdb818:161e073d7b8:-7fd4', 'RUL-78fba29f:161df51b937:-4a59', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fe3', 'RC42bdb818:161e073d7b8:-7fe3', 'RUL-78fba29f:161df51b937:-4b72', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7fe6', 'RC42bdb818:161e073d7b8:-7fe6', 'RUL-78fba29f:161df51b937:-4b72', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7ff0', 'RC42bdb818:161e073d7b8:-7ff0', 'RUL-78fba29f:161df51b937:-4bf1', 'BILLITEM', 'rptis.landtax.facts.RPTBillItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC42bdb818:161e073d7b8:-7ff2', 'RC42bdb818:161e073d7b8:-7ff2', 'RUL-78fba29f:161df51b937:-4bf1', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC67caf065:1724e308e34:-7336', 'RC67caf065:1724e308e34:-7336', 'RUL6afb50c:1724e644945:-6621', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC67caf065:1724e308e34:-7338', 'RC67caf065:1724e308e34:-7338', 'RUL6afb50c:1724e644945:-6621', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RC67caf065:1724e308e34:-738e', 'RC67caf065:1724e308e34:-738e', 'RUL6afb50c:1724e644945:-6b4e', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-15f7fe9f:15cf6ec9fa5:-7fc1', 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-15f7fe9f:15cf6ec9fa5:-7fc2', 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'AL', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f0d', 'RC-293918d4:16209768e19:-7f0f', 'RUL713e35a1:1620963487c:-54ee', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f18', 'RC-293918d4:16209768e19:-7f19', 'RUL713e35a1:1620963487c:-5520', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f27', 'RC-293918d4:16209768e19:-7f28', 'RUL713e35a1:1620963487c:-5552', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f34', 'RC-293918d4:16209768e19:-7f36', 'RUL713e35a1:1620963487c:-5584', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f49', 'RC-293918d4:16209768e19:-7f4b', 'RUL713e35a1:1620963487c:-583b', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f57', 'RC-293918d4:16209768e19:-7f58', 'RUL713e35a1:1620963487c:-588e', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f63', 'RC-293918d4:16209768e19:-7f64', 'RUL713e35a1:1620963487c:-58d7', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f70', 'RC-293918d4:16209768e19:-7f72', 'RUL713e35a1:1620963487c:-5939', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f7c', 'RC-293918d4:16209768e19:-7f7e', 'RUL713e35a1:1620963487c:-5972', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f8a', 'RC-293918d4:16209768e19:-7f8b', 'RUL713e35a1:1620963487c:-59d5', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e39', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'RUL-79a9a347:15cfcae84de:-707b', 'MV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e3a', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'RUL-79a9a347:15cfcae84de:-707b', 'AL', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7edd', 'RC-6bcddeab:16188c09983:-7edf', 'RUL5d750d7e:161889cc785:-5f54', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ede', 'RC-6bcddeab:16188c09983:-7edf', 'RUL5d750d7e:161889cc785:-5f54', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ee3', 'RC-6bcddeab:16188c09983:-7ee5', 'RUL5d750d7e:161889cc785:-5f54', 'CURRDATE', 'date', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0a', 'RC-6bcddeab:16188c09983:-7f0b', 'RUL5d750d7e:161889cc785:-61f2', 'CURRDATE', 'date', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0f', 'RC-6bcddeab:16188c09983:-7f11', 'RUL5d750d7e:161889cc785:-61f2', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f10', 'RC-6bcddeab:16188c09983:-7f11', 'RUL5d750d7e:161889cc785:-61f2', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7fd6', 'RC-6bcddeab:16188c09983:-7fd7', 'RUL5d750d7e:161889cc785:-72c0', 'CDATE', 'date', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c67', 'RC13423d65:162270a87db:-7c69', 'RUL-621d5f20:16222e9bf6d:-bc0', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c68', 'RC13423d65:162270a87db:-7c69', 'RUL-621d5f20:16222e9bf6d:-bc0', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c6b', 'RC13423d65:162270a87db:-7c6d', 'RUL-621d5f20:16222e9bf6d:-bc0', 'TAX', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7ccf', 'RC13423d65:162270a87db:-7cd0', 'RUL-621d5f20:16222e9bf6d:-19d5', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd4', 'RC13423d65:162270a87db:-7cd6', 'RUL-621d5f20:16222e9bf6d:-19d5', 'NMON', 'integer', '3');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd5', 'RC13423d65:162270a87db:-7cd6', 'RUL-621d5f20:16222e9bf6d:-19d5', 'TAX', 'decimal', '4');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC13524a8b:161b645b0bf:-7fe1', 'RC13524a8b:161b645b0bf:-7fe2', 'RUL-7deff7e5:161b60a3048:-5a7e', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC16a7ee38:15cfcd300fe:-7fb9', 'RC16a7ee38:15cfcd300fe:-7fba', 'RUL-79a9a347:15cfcae84de:-55fd', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC16a7ee38:15cfcd300fe:-7fbb', 'RC16a7ee38:15cfcd300fe:-7fbc', 'RUL-79a9a347:15cfcae84de:-55fd', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fb9', 'RC42bdb818:161e073d7b8:-7fba', 'RUL-78fba29f:161df51b937:-4837', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fbb', 'RC42bdb818:161e073d7b8:-7fbc', 'RUL-78fba29f:161df51b937:-4837', 'BRGYID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fc5', 'RC42bdb818:161e073d7b8:-7fc6', 'RUL-78fba29f:161df51b937:-4951', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fc7', 'RC42bdb818:161e073d7b8:-7fc8', 'RUL-78fba29f:161df51b937:-4951', 'BRGYID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fd0', 'RC42bdb818:161e073d7b8:-7fd1', 'RUL-78fba29f:161df51b937:-4a59', 'BRGYID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fd2', 'RC42bdb818:161e073d7b8:-7fd4', 'RUL-78fba29f:161df51b937:-4a59', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fe2', 'RC42bdb818:161e073d7b8:-7fe3', 'RUL-78fba29f:161df51b937:-4b72', 'BRGYID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fe4', 'RC42bdb818:161e073d7b8:-7fe6', 'RUL-78fba29f:161df51b937:-4b72', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fef', 'RC42bdb818:161e073d7b8:-7ff0', 'RUL-78fba29f:161df51b937:-4bf1', 'AMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7ff1', 'RC42bdb818:161e073d7b8:-7ff2', 'RUL-78fba29f:161df51b937:-4bf1', 'BRGYID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7332', 'RC67caf065:1724e308e34:-7336', 'RUL6afb50c:1724e644945:-6621', 'NMON', 'integer', '5');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7334', 'RC67caf065:1724e308e34:-7336', 'RUL6afb50c:1724e644945:-6621', 'TAX', 'decimal', '4');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7339', 'RC67caf065:1724e308e34:-733b', 'RUL6afb50c:1724e644945:-6621', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-733a', 'RC67caf065:1724e308e34:-733b', 'RUL6afb50c:1724e644945:-6621', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7383', 'RC67caf065:1724e308e34:-7385', 'RUL6afb50c:1724e644945:-6b4e', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7384', 'RC67caf065:1724e308e34:-7385', 'RUL6afb50c:1724e644945:-6b4e', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCC67caf065:1724e308e34:-738c', 'RC67caf065:1724e308e34:-738e', 'RUL6afb50c:1724e644945:-6b4e', 'TAX', 'decimal', '4');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-103fed47:146ffb40356:-7d40', 'RCOND-103fed47:146ffb40356:-7d40', 'RUL3e2b89cb:146ff734573:-7dcc', 'RPU', 'rptis.bldg.facts.BldgRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-13574fd2:1621b509f0b:-71e5', 'RCOND-13574fd2:1621b509f0b:-71e5', 'RUL-2486b0ca:146fff66c3e:-4697', 'RPU', 'rptis.bldg.facts.BldgRPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-2bf1', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'BU', 'rptis.bldg.facts.BldgUse', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3888', 'RCOND-2486b0ca:146fff66c3e:-3888', 'RUL-2486b0ca:146fff66c3e:-38e4', 'BF', 'rptis.bldg.facts.BldgFloor', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3ed1', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'RUL-2486b0ca:146fff66c3e:-4192', 'BU', 'rptis.bldg.facts.BldgUse', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-3f91', 'RCOND-2486b0ca:146fff66c3e:-3f91', 'RUL-2486b0ca:146fff66c3e:-4192', 'RPU', 'rptis.bldg.facts.BldgRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-445d', 'RCOND-2486b0ca:146fff66c3e:-445d', 'RUL-2486b0ca:146fff66c3e:-4697', 'BS', 'rptis.bldg.facts.BldgStructure', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-2486b0ca:146fff66c3e:-6aad', 'RCOND-2486b0ca:146fff66c3e:-6aad', 'RUL-2486b0ca:146fff66c3e:-6b05', 'BF', 'rptis.bldg.facts.BldgFloor', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-28dc975:156bcab666c:-5f3d', 'RCOND-28dc975:156bcab666c:-5f3d', 'RUL-3e8edbea:156bc08656a:-5f05', 'VAR', 'rptis.facts.RPTVariable', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-28dc975:156bcab666c:-6051', 'RCOND-28dc975:156bcab666c:-6051', 'RUL-3e8edbea:156bc08656a:-5f05', 'RPU', 'rptis.facts.RPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-46fca07e:14c545f3e6a:-3353', 'RCOND-46fca07e:14c545f3e6a:-3353', 'RUL-46fca07e:14c545f3e6a:-33b4', 'BF', 'rptis.bldg.facts.BldgFloor', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-46fca07e:14c545f3e6a:-34b0', 'RCOND-46fca07e:14c545f3e6a:-34b0', 'RUL-46fca07e:14c545f3e6a:-350f', 'BU', 'rptis.bldg.facts.BldgUse', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-46fca07e:14c545f3e6a:-7707', 'RCOND-46fca07e:14c545f3e6a:-7707', 'RUL-46fca07e:14c545f3e6a:-7740', 'LA', 'rptis.land.facts.LandDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-46fca07e:14c545f3e6a:-786f', 'RCOND-46fca07e:14c545f3e6a:-786f', 'RUL-46fca07e:14c545f3e6a:-7a8b', 'LA', 'rptis.land.facts.LandDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-585c89e6:16156f39eeb:-7586', 'RCOND-585c89e6:16156f39eeb:-7586', 'RUL-585c89e6:16156f39eeb:-770f', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-59249a93:1614f57bd58:-7d29', 'RCOND-59249a93:1614f57bd58:-7d29', 'RUL-59249a93:1614f57bd58:-7d49', 'AVINFO', 'rptis.landtax.facts.AssessedValue', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-5e76cf73:14d69e9c549:-701c', 'RCOND-5e76cf73:14d69e9c549:-701c', 'RUL-5e76cf73:14d69e9c549:-7084', 'LA', 'rptis.land.facts.LandDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-5e76cf73:14d69e9c549:-7e5d', 'RCOND-5e76cf73:14d69e9c549:-7e5d', 'RUL-5e76cf73:14d69e9c549:-7fd4', 'ADJ', 'rptis.land.facts.LandAdjustment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-60c99d04:1470b276e7f:-7dd3', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BU', 'rptis.bldg.facts.BldgUse', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-60c99d04:1470b276e7f:-7e2a', 'RCOND-60c99d04:1470b276e7f:-7e2a', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BS', 'rptis.bldg.facts.BldgStructure', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-6c4ec747:154bd626092:-55c3', 'RCOND-6c4ec747:154bd626092:-55c3', 'RUL-6c4ec747:154bd626092:-5616', 'MACH', 'rptis.mach.facts.MachineDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-762e9176:15d067a9c42:-5928', 'RCOND-762e9176:15d067a9c42:-5928', 'RUL-762e9176:15d067a9c42:-5aa0', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-762e9176:15d067a9c42:-5a4b', 'RCOND-762e9176:15d067a9c42:-5a4b', 'RUL-762e9176:15d067a9c42:-5aa0', 'VAR', 'rptis.facts.RPTVariable', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-762e9176:15d067a9c42:-5d56', 'RCOND-762e9176:15d067a9c42:-5d56', 'RUL-762e9176:15d067a9c42:-5e26', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-762e9176:15d067a9c42:-5dd2', 'RCOND-762e9176:15d067a9c42:-5dd2', 'RUL-762e9176:15d067a9c42:-5e26', 'RA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-78fba29f:161df51b937:-7478', 'RCOND-78fba29f:161df51b937:-7478', 'RUL-78fba29f:161df51b937:-74da', 'RLTS', 'rptis.landtax.facts.RPTLedgerTaxSummaryFact', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-1e48', 'RCOND-79a9a347:15cfcae84de:-1e48', 'RUL-79a9a347:15cfcae84de:-1ed3', 'VAR', 'rptis.facts.RPTVariable', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-1e8b', 'RCOND-79a9a347:15cfcae84de:-1e8b', 'RUL-79a9a347:15cfcae84de:-1ed3', 'RPU', 'rptis.facts.RPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-20e8', 'RCOND-79a9a347:15cfcae84de:-20e8', 'RUL-79a9a347:15cfcae84de:-2167', 'RA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-5af4', 'RCOND-79a9a347:15cfcae84de:-5af4', 'RUL-79a9a347:15cfcae84de:-6f2a', 'VAR', 'rptis.facts.RPTVariable', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-6222', 'RCOND-79a9a347:15cfcae84de:-6222', 'RUL-79a9a347:15cfcae84de:-6401', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-637a', 'RCOND-79a9a347:15cfcae84de:-637a', 'RUL-79a9a347:15cfcae84de:-6401', 'RA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-6ebc', 'RCOND-79a9a347:15cfcae84de:-6ebc', 'RUL-79a9a347:15cfcae84de:-6f2a', 'RPU', 'rptis.facts.RPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-928', 'RCOND-79a9a347:15cfcae84de:-928', 'RUL-79a9a347:15cfcae84de:-b33', 'MACH', 'rptis.mach.facts.MachineDetail', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-a77', 'RCOND-79a9a347:15cfcae84de:-a77', 'RUL-79a9a347:15cfcae84de:-b33', 'MAU', 'rptis.mach.facts.MachineActualUse', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:-c6d', 'RCOND-79a9a347:15cfcae84de:-c6d', 'RUL-79a9a347:15cfcae84de:-2167', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:4fcd', 'RCOND-79a9a347:15cfcae84de:4fcd', 'RUL-79a9a347:15cfcae84de:4f83', 'RA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:508d', 'RCOND-79a9a347:15cfcae84de:508d', 'RUL-79a9a347:15cfcae84de:4f83', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:553c', 'RCOND-79a9a347:15cfcae84de:553c', 'RUL-79a9a347:15cfcae84de:549e', 'RPU', 'rptis.facts.RPU', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:55ab', 'RCOND-79a9a347:15cfcae84de:55ab', 'RUL-79a9a347:15cfcae84de:549e', 'VAR', 'rptis.facts.RPTVariable', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-79a9a347:15cfcae84de:fb4', 'RCOND-79a9a347:15cfcae84de:fb4', 'RUL-79a9a347:15cfcae84de:f6c', 'PTD', 'rptis.planttree.facts.PlantTreeDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND-a35dd35:14e51ec3311:-5d14', 'RCOND-a35dd35:14e51ec3311:-5d14', 'RUL-a35dd35:14e51ec3311:-5d4c', 'MRPU', 'rptis.misc.facts.MiscRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1441128c:1471efa4c1c:-6c2f', 'RCOND1441128c:1471efa4c1c:-6c2f', 'RUL1441128c:1471efa4c1c:-6c93', 'BA', 'rptis.facts.RPUAssessment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1441128c:1471efa4c1c:-6d84', 'RCOND1441128c:1471efa4c1c:-6d84', 'RUL1441128c:1471efa4c1c:-6eaa', 'BU', 'rptis.bldg.facts.BldgUse', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1b4af871:14e3cc46e09:-2fc5', 'RCOND1b4af871:14e3cc46e09:-2fc5', 'RUL1b4af871:14e3cc46e09:-301e', 'MI', 'rptis.misc.facts.MiscItem', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1b4af871:14e3cc46e09:-2fe8', 'RCOND1b4af871:14e3cc46e09:-2fe8', 'RUL1b4af871:14e3cc46e09:-301e', 'MRPU', 'rptis.misc.facts.MiscRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1b4af871:14e3cc46e09:-31fc', 'RCOND1b4af871:14e3cc46e09:-31fc', 'RUL1b4af871:14e3cc46e09:-3341', 'MI', 'rptis.misc.facts.MiscItem', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1b4af871:14e3cc46e09:-3242', 'RCOND1b4af871:14e3cc46e09:-3242', 'RUL1b4af871:14e3cc46e09:-3341', 'MRPU', 'rptis.misc.facts.MiscRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e772168:14c5a447e35:-65bc', 'RCOND1e772168:14c5a447e35:-65bc', 'RUL1e772168:14c5a447e35:-669c', 'MACH', 'rptis.mach.facts.MachineDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e772168:14c5a447e35:-6cfc', 'RCOND1e772168:14c5a447e35:-6cfc', 'RUL1e772168:14c5a447e35:-6d2f', 'MACH', 'rptis.mach.facts.MachineDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e772168:14c5a447e35:-7dce', 'RCOND1e772168:14c5a447e35:-7dce', 'RUL1e772168:14c5a447e35:-7e01', 'MACH', 'rptis.mach.facts.MachineDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e983c10:147f2149816:373', 'RCOND1e983c10:147f2149816:373', 'RUL1e983c10:147f2149816:2bc', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e983c10:147f2149816:4df', 'RCOND1e983c10:147f2149816:4df', 'RUL1e983c10:147f2149816:437', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1e983c10:147f2149816:675', 'RCOND1e983c10:147f2149816:675', 'RUL1e983c10:147f2149816:5a3', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND1ff29cd0:1572617f8d8:-7d30', 'RCOND1ff29cd0:1572617f8d8:-7d30', 'RUL-a35dd35:14e51ec3311:-5d4c', 'MI', 'rptis.misc.facts.MiscItem', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND37df8403:14c5405fff0:-7693', 'RCOND37df8403:14c5405fff0:-7693', 'RUL37df8403:14c5405fff0:-76bf', 'PTD', 'rptis.planttree.facts.PlantTreeDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND3b800abe:14d2b978f55:-6196', 'RCOND3b800abe:14d2b978f55:-6196', 'RUL3b800abe:14d2b978f55:-61fb', 'BU', 'rptis.bldg.facts.BldgUse', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND3b800abe:14d2b978f55:-6339', 'RCOND3b800abe:14d2b978f55:-6339', 'RUL3b800abe:14d2b978f55:-63a0', 'BF', 'rptis.bldg.facts.BldgFloor', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND3b800abe:14d2b978f55:-7d69', 'RCOND3b800abe:14d2b978f55:-7d69', 'RUL3b800abe:14d2b978f55:-7e09', 'ADJ', 'rptis.bldg.facts.BldgAdjustment', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND3de2e0bf:15165926561:-7b18', 'RCOND3de2e0bf:15165926561:-7b18', 'RUL3de2e0bf:15165926561:-7bfc', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND3fb43b91:14ccf782188:-5fd2', 'RCOND3fb43b91:14ccf782188:-5fd2', 'RUL3fb43b91:14ccf782188:-6008', 'PTD', 'rptis.planttree.facts.PlantTreeDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND49a3c540:14e51feb8f6:-76da', 'RCOND49a3c540:14e51feb8f6:-76da', 'RUL49a3c540:14e51feb8f6:-77d2', 'VAR2', 'rptis.misc.facts.MiscVariable', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND49a3c540:14e51feb8f6:-774e', 'RCOND49a3c540:14e51feb8f6:-774e', 'RUL49a3c540:14e51feb8f6:-77d2', 'VAR1', 'rptis.facts.RPTVariable', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND49a3c540:14e51feb8f6:-779a', 'RCOND49a3c540:14e51feb8f6:-779a', 'RUL49a3c540:14e51feb8f6:-77d2', 'MRPU', 'rptis.misc.facts.MiscRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND4bf973aa:1562a233196:-500e', 'RCOND4bf973aa:1562a233196:-500e', 'RUL4bf973aa:1562a233196:-5055', 'MACH', 'rptis.mach.facts.MachineDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND4e46261d:14f924c6b53:-7c57', 'RCOND4e46261d:14f924c6b53:-7c57', 'RUL4e46261d:14f924c6b53:-7d9b', 'BU', 'rptis.bldg.facts.BldgUse', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND4e46261d:14f924c6b53:-7d37', 'RCOND4e46261d:14f924c6b53:-7d37', 'RUL4e46261d:14f924c6b53:-7d9b', 'RPU', 'rptis.bldg.facts.BldgRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND4fc9c2c7:176cac860ed:-75f6', 'RCOND4fc9c2c7:176cac860ed:-75f6', 'RUL4fc9c2c7:176cac860ed:-76d7', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5022d8ba:1589ae965a4:-7c5c', 'RCOND5022d8ba:1589ae965a4:-7c5c', 'RUL5022d8ba:1589ae965a4:-7c9c', 'PTD', 'rptis.planttree.facts.PlantTreeDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND59614e16:14c5e56ecc8:-7c8f', 'RCOND59614e16:14c5e56ecc8:-7c8f', 'RUL59614e16:14c5e56ecc8:-7cbf', 'MI', 'rptis.misc.facts.MiscItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND59614e16:14c5e56ecc8:-7dcb', 'RCOND59614e16:14c5e56ecc8:-7dcb', 'RUL59614e16:14c5e56ecc8:-7dfb', 'MI', 'rptis.misc.facts.MiscItem', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5a030c2b:17277b1ddc5:-7e0f', 'RCOND5a030c2b:17277b1ddc5:-7e0f', 'RUL5a030c2b:17277b1ddc5:-7e65', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5b4ac915:147baaa06b4:-6da4', 'RCOND5b4ac915:147baaa06b4:-6da4', 'RUL5b4ac915:147baaa06b4:-6f31', 'LA', 'rptis.land.facts.LandDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5b84d618:1615428187f:-622b', 'RCOND5b84d618:1615428187f:-622b', 'RUL5b84d618:1615428187f:-62e3', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5b84d618:1615428187f:-66fa', 'RCOND5b84d618:1615428187f:-66fa', 'RUL5b84d618:1615428187f:-67ce', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5d750d7e:161889cc785:-6f08', 'RCOND5d750d7e:161889cc785:-6f08', 'RUL5d750d7e:161889cc785:-7301', 'BILL', 'rptis.landtax.facts.Bill', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND5d750d7e:161889cc785:-7066', 'RCOND5d750d7e:161889cc785:-7066', 'RUL5d750d7e:161889cc785:-7301', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND634d9a3c:161503ff1dc:-586c', 'RCOND634d9a3c:161503ff1dc:-586c', 'RUL634d9a3c:161503ff1dc:-5b2a', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND650f832b:14c53e6ce93:-79a1', 'RCOND650f832b:14c53e6ce93:-79a1', 'RUL650f832b:14c53e6ce93:-79cd', 'PTD', 'rptis.planttree.facts.PlantTreeDetail', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND6afb50c:1724e644945:-5f45', 'RCOND6afb50c:1724e644945:-5f45', 'RUL6afb50c:1724e644945:-602d', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND6afb50c:1724e644945:-6144', 'RCOND6afb50c:1724e644945:-6144', 'RUL6afb50c:1724e644945:-62f2', 'RLI', 'rptis.landtax.facts.RPTLedgerItemFact', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND6afb50c:1724e644945:-61d4', 'RCOND6afb50c:1724e644945:-61d4', 'RUL6afb50c:1724e644945:-62f2', 'RL', 'rptis.landtax.facts.RPTLedgerFact', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCOND6d174068:14e3de9c20b:-7f93', 'RCOND6d174068:14e3de9c20b:-7f93', 'RUL6d174068:14e3de9c20b:-7fcb', 'MRPU', 'rptis.misc.facts.MiscRPU', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-103fed47:146ffb40356:-7c7c', 'RCOND-103fed47:146ffb40356:-7d40', 'RUL3e2b89cb:146ff734573:-7dcc', 'YRCOMPLETED', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-103fed47:146ffb40356:-7ce5', 'RCOND-103fed47:146ffb40356:-7d40', 'RUL3e2b89cb:146ff734573:-7dcc', 'YRAPPRAISED', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2b45', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'ADJ', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2b8c', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'DEP', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2bc5', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-382b', 'RCOND-2486b0ca:146fff66c3e:-3888', 'RUL-2486b0ca:146fff66c3e:-38e4', 'ADJ', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-3860', 'RCOND-2486b0ca:146fff66c3e:-3888', 'RUL-2486b0ca:146fff66c3e:-38e4', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-3f19', 'RCOND-2486b0ca:146fff66c3e:-3f91', 'RUL-2486b0ca:146fff66c3e:-4192', 'DPRATE', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-6a5a', 'RCOND-2486b0ca:146fff66c3e:-6aad', 'RUL-2486b0ca:146fff66c3e:-6b05', 'UV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-6a8b', 'RCOND-2486b0ca:146fff66c3e:-6aad', 'RUL-2486b0ca:146fff66c3e:-6b05', 'AREA', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-28dc975:156bcab666c:-5ed8', 'RCOND-28dc975:156bcab666c:-5f3d', 'RUL-3e8edbea:156bc08656a:-5f05', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-2ef3c345:147ed584975:-7e3d', 'RCOND-60c99d04:1470b276e7f:-7e2a', 'RUL-60c99d04:1470b276e7f:-7ecc', 'TOTALAREA', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-332b', 'RCOND-46fca07e:14c545f3e6a:-3353', 'RUL-46fca07e:14c545f3e6a:-33b4', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-3481', 'RCOND-46fca07e:14c545f3e6a:-34b0', 'RUL-46fca07e:14c545f3e6a:-350f', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-7678', 'RCOND-46fca07e:14c545f3e6a:-7707', 'RUL-46fca07e:14c545f3e6a:-7740', 'ADJ', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-76c6', 'RCOND-46fca07e:14c545f3e6a:-7707', 'RUL-46fca07e:14c545f3e6a:-7740', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-77f2', 'RCOND-46fca07e:14c545f3e6a:-786f', 'RUL-46fca07e:14c545f3e6a:-7a8b', 'UV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-783a', 'RCOND-46fca07e:14c545f3e6a:-786f', 'RUL-46fca07e:14c545f3e6a:-7a8b', 'AREA', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-585c89e6:16156f39eeb:-75f5', 'RCOND-585c89e6:16156f39eeb:-760c', 'RUL-585c89e6:16156f39eeb:-770f', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-59249a93:1614f57bd58:-7d27', 'RCOND-59249a93:1614f57bd58:-7d29', 'RUL-59249a93:1614f57bd58:-7d49', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-59249a93:1614f57bd58:-7d28', 'RCOND-59249a93:1614f57bd58:-7d29', 'RUL-59249a93:1614f57bd58:-7d49', 'YR', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6f25', 'RCOND-5e76cf73:14d69e9c549:-701c', 'RUL-5e76cf73:14d69e9c549:-7084', 'AUADJ', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6f83', 'RCOND-5e76cf73:14d69e9c549:-701c', 'RUL-5e76cf73:14d69e9c549:-7084', 'LVADJ', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6fd3', 'RCOND-5e76cf73:14d69e9c549:-701c', 'RUL-5e76cf73:14d69e9c549:-7084', 'ADJ', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-7e44', 'RCOND-5e76cf73:14d69e9c549:-7e5d', 'RUL-5e76cf73:14d69e9c549:-7fd4', 'ADJAMOUNT', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-60c99d04:1470b276e7f:-7d64', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BASEVALUE', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-621d5f20:16222e9bf6d:-2457', 'RCOND5b84d618:1615428187f:-677a', 'RUL5b84d618:1615428187f:-67ce', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-6c4ec747:154bd626092:-5554', 'RCOND-6c4ec747:154bd626092:-55c3', 'RUL-6c4ec747:154bd626092:-5616', 'SWORNAMT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-59dc', 'RCOND-762e9176:15d067a9c42:-5a4b', 'RUL-762e9176:15d067a9c42:-5aa0', 'TOTALAV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5d1b', 'RCOND-762e9176:15d067a9c42:-5d56', 'RUL-762e9176:15d067a9c42:-5e26', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5da3', 'RCOND-762e9176:15d067a9c42:-5dd2', 'RUL-762e9176:15d067a9c42:-5e26', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-1dd7', 'RCOND-79a9a347:15cfcae84de:-1e48', 'RUL-79a9a347:15cfcae84de:-1ed3', 'TOTALAV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-20b9', 'RCOND-79a9a347:15cfcae84de:-20e8', 'RUL-79a9a347:15cfcae84de:-2167', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-5a45', 'RCOND-79a9a347:15cfcae84de:-5af4', 'RUL-79a9a347:15cfcae84de:-6f2a', 'AV', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-5ccd', 'RCOND-79a9a347:15cfcae84de:-6ebc', 'RUL-79a9a347:15cfcae84de:-6f2a', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-61bf', 'RCOND-79a9a347:15cfcae84de:-6222', 'RUL-79a9a347:15cfcae84de:-6401', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-625', 'RCOND-79a9a347:15cfcae84de:-928', 'RUL-79a9a347:15cfcae84de:-b33', 'AL', 'decimal', '3');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-62a7', 'RCOND-79a9a347:15cfcae84de:-637a', 'RUL-79a9a347:15cfcae84de:-6401', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-858', 'RCOND-79a9a347:15cfcae84de:-928', 'RUL-79a9a347:15cfcae84de:-b33', 'MV', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-c0a', 'RCOND-79a9a347:15cfcae84de:-c6d', 'RUL-79a9a347:15cfcae84de:-2167', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:1012', 'RCOND-79a9a347:15cfcae84de:fb4', 'RUL-79a9a347:15cfcae84de:f6c', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:1089', 'RCOND-79a9a347:15cfcae84de:fb4', 'RUL-79a9a347:15cfcae84de:f6c', 'AL', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:4ffe', 'RCOND-79a9a347:15cfcae84de:4fcd', 'RUL-79a9a347:15cfcae84de:4f83', 'AV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:50f0', 'RCOND-79a9a347:15cfcae84de:508d', 'RUL-79a9a347:15cfcae84de:4f83', 'RPUID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:5657', 'RCOND-79a9a347:15cfcae84de:55ab', 'RUL-79a9a347:15cfcae84de:549e', 'TOTALAV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST-a35dd35:14e51ec3311:-5cc7', 'RCOND-a35dd35:14e51ec3311:-5d14', 'RUL-a35dd35:14e51ec3311:-5d4c', 'SWORNAMT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST102ab3e1:147190e9fe4:-26f3', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'RUL-2486b0ca:146fff66c3e:-4192', 'ADJUSTMENT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST102ab3e1:147190e9fe4:-272e', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'RUL-2486b0ca:146fff66c3e:-4192', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1441128c:1471efa4c1c:-6d47', 'RCOND1441128c:1471efa4c1c:-6d84', 'RUL1441128c:1471efa4c1c:-6eaa', 'ACTUALUSE', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1b4af871:14e3cc46e09:-2f4b', 'RCOND1b4af871:14e3cc46e09:-2fc5', 'RUL1b4af871:14e3cc46e09:-301e', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1b4af871:14e3cc46e09:-31dc', 'RCOND1b4af871:14e3cc46e09:-31fc', 'RUL1b4af871:14e3cc46e09:-3341', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-65a1', 'RCOND1e772168:14c5a447e35:-65bc', 'RUL1e772168:14c5a447e35:-669c', 'DEP', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-6ce4', 'RCOND1e772168:14c5a447e35:-6cfc', 'RUL1e772168:14c5a447e35:-6d2f', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-7db8', 'RCOND1e772168:14c5a447e35:-7dce', 'RUL1e772168:14c5a447e35:-7e01', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e983c10:147f2149816:311', 'RCOND1e983c10:147f2149816:2ff', 'RUL1e983c10:147f2149816:2bc', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e983c10:147f2149816:48b', 'RCOND1e983c10:147f2149816:479', 'RUL1e983c10:147f2149816:437', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1e983c10:147f2149816:621', 'RCOND1e983c10:147f2149816:60f', 'RUL1e983c10:147f2149816:5a3', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST1ff29cd0:1572617f8d8:-7d08', 'RCOND1ff29cd0:1572617f8d8:-7d30', 'RUL-a35dd35:14e51ec3311:-5d4c', 'DPRATE', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST37df8403:14c5405fff0:-7656', 'RCOND37df8403:14c5405fff0:-7693', 'RUL37df8403:14c5405fff0:-76bf', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-6160', 'RCOND3b800abe:14d2b978f55:-6196', 'RUL3b800abe:14d2b978f55:-61fb', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-630b', 'RCOND3b800abe:14d2b978f55:-6339', 'RUL3b800abe:14d2b978f55:-63a0', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-7cdb', 'RCOND3b800abe:14d2b978f55:-7d69', 'RUL3b800abe:14d2b978f55:-7e09', 'ADJAMOUNT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3de2e0bf:15165926561:-7ba2', 'RCOND3de2e0bf:15165926561:-7bb4', 'RUL3de2e0bf:15165926561:-7bfc', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3fb43b91:14ccf782188:-5f2b', 'RCOND3fb43b91:14ccf782188:-5fd2', 'RUL3fb43b91:14ccf782188:-6008', 'ADJRATE', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST3fb43b91:14ccf782188:-5f95', 'RCOND3fb43b91:14ccf782188:-5fd2', 'RUL3fb43b91:14ccf782188:-6008', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST40c0977:151a9b0cb60:-7d29', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'RUL-60c99d04:1470b276e7f:-7ecc', 'BUAREA', 'decimal', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-67ae', 'RCOND1b4af871:14e3cc46e09:-2fe8', 'RUL1b4af871:14e3cc46e09:-301e', 'REFID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-6bc7', 'RCOND1b4af871:14e3cc46e09:-3242', 'RUL1b4af871:14e3cc46e09:-3341', 'REFID', 'string', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-769e', 'RCOND49a3c540:14e51feb8f6:-76da', 'RUL49a3c540:14e51feb8f6:-77d2', 'TOTALMV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-7712', 'RCOND49a3c540:14e51feb8f6:-774e', 'RUL49a3c540:14e51feb8f6:-77d2', 'TOTALBMV', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4bf973aa:1562a233196:-4d8d', 'RCOND4bf973aa:1562a233196:-500e', 'RUL4bf973aa:1562a233196:-5055', 'DEPRATE', 'boolean', '2');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4bf973aa:1562a233196:-4f81', 'RCOND4bf973aa:1562a233196:-500e', 'RUL4bf973aa:1562a233196:-5055', 'SWORNAMT', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7bc5', 'RCOND4e46261d:14f924c6b53:-7c57', 'RUL4e46261d:14f924c6b53:-7d9b', 'ADJUSTMENT', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7c0e', 'RCOND4e46261d:14f924c6b53:-7c57', 'RUL4e46261d:14f924c6b53:-7d9b', 'SWORNAMT', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7cc1', 'RCOND4e46261d:14f924c6b53:-7d37', 'RUL4e46261d:14f924c6b53:-7d9b', 'DPRATE', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4fc9c2c7:176cac860ed:-752d', 'RCOND4fc9c2c7:176cac860ed:-75f6', 'RUL4fc9c2c7:176cac860ed:-76d7', 'TAX', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST4fc9c2c7:176cac860ed:-7674', 'RCOND4fc9c2c7:176cac860ed:-768b', 'RUL4fc9c2c7:176cac860ed:-76d7', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7c46', 'RCOND59614e16:14c5e56ecc8:-7c8f', 'RUL59614e16:14c5e56ecc8:-7cbf', 'DEP', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7c6f', 'RCOND59614e16:14c5e56ecc8:-7c8f', 'RUL59614e16:14c5e56ecc8:-7cbf', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7d8b', 'RCOND59614e16:14c5e56ecc8:-7dcb', 'RUL59614e16:14c5e56ecc8:-7dfb', 'DEPRATE', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7db3', 'RCOND59614e16:14c5e56ecc8:-7dcb', 'RUL59614e16:14c5e56ecc8:-7dfb', 'BMV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5b4ac915:147baaa06b4:-6d59', 'RCOND5b4ac915:147baaa06b4:-6da4', 'RUL5b4ac915:147baaa06b4:-6f31', 'CLASS', 'rptis.facts.Classification', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6159', 'RCOND5b84d618:1615428187f:-622b', 'RUL5b84d618:1615428187f:-62e3', 'TAX', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-628c', 'RCOND5b84d618:1615428187f:-62a3', 'RUL5b84d618:1615428187f:-62e3', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6624', 'RCOND5b84d618:1615428187f:-66fa', 'RUL5b84d618:1615428187f:-67ce', 'TAX', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6763', 'RCOND5b84d618:1615428187f:-677a', 'RUL5b84d618:1615428187f:-67ce', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-6e27', 'RCOND5d750d7e:161889cc785:-6f08', 'RUL5d750d7e:161889cc785:-7301', 'CURRDATE', 'date', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-6fd3', 'RCOND5d750d7e:161889cc785:-7066', 'RUL5d750d7e:161889cc785:-7301', 'LAST_QTR_PAID', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-7029', 'RCOND5d750d7e:161889cc785:-7066', 'RUL5d750d7e:161889cc785:-7301', 'LAST_YR_PAID', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-70ee', 'RCOND5d750d7e:161889cc785:-713b', 'RUL5d750d7e:161889cc785:-7301', 'CQTR', 'integer', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-7124', 'RCOND5d750d7e:161889cc785:-713b', 'RUL5d750d7e:161889cc785:-7301', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST634d9a3c:161503ff1dc:-580e', 'RCOND634d9a3c:161503ff1dc:-586c', 'RUL634d9a3c:161503ff1dc:-5b2a', 'AV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST650f832b:14c53e6ce93:-795e', 'RCOND650f832b:14c53e6ce93:-79a1', 'RUL650f832b:14c53e6ce93:-79cd', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-5e5f', 'RCOND6afb50c:1724e644945:-5f45', 'RUL6afb50c:1724e644945:-602d', 'TAX', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-5fd7', 'RCOND6afb50c:1724e644945:-5fea', 'RUL6afb50c:1724e644945:-602d', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-6295', 'RCOND6afb50c:1724e644945:-62a7', 'RUL6afb50c:1724e644945:-62f2', 'CY', 'integer', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-69fd', 'RC67caf065:1724e308e34:-738e', 'RUL6afb50c:1724e644945:-6b4e', 'NMON', 'integer', '6');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6d174068:14e3de9c20b:-7f46', 'RCOND6d174068:14e3de9c20b:-7f93', 'RUL6d174068:14e3de9c20b:-7fcb', 'AL', 'decimal', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST6d174068:14e3de9c20b:-7f73', 'RCOND6d174068:14e3de9c20b:-7f93', 'RUL6d174068:14e3de9c20b:-7fcb', 'MV', 'decimal', '0');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-1ec6', 'RC-293918d4:16209768e19:-7f8d', 'RUL713e35a1:1620963487c:-59d5', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-206e', 'RC-293918d4:16209768e19:-7f7b', 'RUL713e35a1:1620963487c:-5972', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2218', 'RC-293918d4:16209768e19:-7f6f', 'RUL713e35a1:1620963487c:-5939', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-23c0', 'RC-293918d4:16209768e19:-7f66', 'RUL713e35a1:1620963487c:-58d7', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2568', 'RC-293918d4:16209768e19:-7f5a', 'RUL713e35a1:1620963487c:-588e', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2710', 'RC-293918d4:16209768e19:-7f48', 'RUL713e35a1:1620963487c:-583b', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-28b8', 'RC-293918d4:16209768e19:-7f33', 'RUL713e35a1:1620963487c:-5584', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2a60', 'RC-293918d4:16209768e19:-7f2a', 'RUL713e35a1:1620963487c:-5552', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2c08', 'RC-293918d4:16209768e19:-7f1b', 'RUL713e35a1:1620963487c:-5520', 'PROVID', 'string', '1');
REPLACE INTO `sys_rule_condition_var` (`objid`, `parentid`, `ruleid`, `varname`, `datatype`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2da6', 'RC-293918d4:16209768e19:-7f0c', 'RUL713e35a1:1620963487c:-54ee', 'PROVID', 'string', '1');

REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-15f7fe9f:15cf6ec9fa5:-7fc1', 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'FACTFLD3afe51b9:146f7088d9c:-7d3d', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-15f7fe9f:15cf6ec9fa5:-7fc2', 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'FACTFLD3afe51b9:146f7088d9c:-7d34', 'assesslevel', 'AL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f0d', 'RC-293918d4:16209768e19:-7f0f', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f0e', 'RC-293918d4:16209768e19:-7f0f', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_SEF_PREVIOUS\",value:\"RPT SEF PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f17', 'RC-293918d4:16209768e19:-7f19', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_SEFINT_PREVIOUS\",value:\"RPT SEF PENALTY PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f18', 'RC-293918d4:16209768e19:-7f19', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f26', 'RC-293918d4:16209768e19:-7f28', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_SEF_CURRENT\",value:\"RPT SEF CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f27', 'RC-293918d4:16209768e19:-7f28', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f34', 'RC-293918d4:16209768e19:-7f36', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f35', 'RC-293918d4:16209768e19:-7f36', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_SEFINT_CURRENT\",value:\"RPT SEF PENALTY CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f49', 'RC-293918d4:16209768e19:-7f4b', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f4a', 'RC-293918d4:16209768e19:-7f4b', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_SEF_ADVANCE\",value:\"RPT SEF ADVANCE\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f56', 'RC-293918d4:16209768e19:-7f58', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_ADVANCE\",value:\"RPT BASIC ADVANCE\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f57', 'RC-293918d4:16209768e19:-7f58', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f62', 'RC-293918d4:16209768e19:-7f64', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASICINT_CURRENT\",value:\"RPT BASIC PENALTY CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f63', 'RC-293918d4:16209768e19:-7f64', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f70', 'RC-293918d4:16209768e19:-7f72', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f71', 'RC-293918d4:16209768e19:-7f72', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_CURRENT\",value:\"RPT BASIC CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f7c', 'RC-293918d4:16209768e19:-7f7e', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f7d', 'RC-293918d4:16209768e19:-7f7e', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASICINT_PREVIOUS\",value:\"RPT BASIC PENALTY PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f89', 'RC-293918d4:16209768e19:-7f8b', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_PREVIOUS\",value:\"RPT BASIC PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-293918d4:16209768e19:-7f8a', 'RC-293918d4:16209768e19:-7f8b', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e37', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'FACTFLD29e16c33:156249fdf8e:-6e66', 'taxable', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '3');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e38', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e39', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'FACTFLD-39192c48:1471ebc2797:-7f7e', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-69b5f604:15cfc6b3e74:-7e3a', 'RC-69b5f604:15cfc6b3e74:-7e3b', 'FACTFLD-39192c48:1471ebc2797:-7f51', 'assesslevel', 'AL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7edd', 'RC-6bcddeab:16188c09983:-7edf', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ede', 'RC-6bcddeab:16188c09983:-7edf', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ee0', 'RC-6bcddeab:16188c09983:-7ee2', 'FACTFLD547c5381:1451ae1cd9c:-797b', 'lastyearpaid', NULL, 'greater than', '>', '1', 'RCC-6bcddeab:16188c09983:-7edd', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ee3', 'RC-6bcddeab:16188c09983:-7ee5', 'FACTFLD5d750d7e:161889cc785:-7702', 'currentdate', 'CURRDATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7ee4', 'RC-6bcddeab:16188c09983:-7ee5', 'FACTFLD-66032c9:16155c11111:-7dca', 'billtoyear', NULL, 'greater than', '>', '1', NULL, 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f09', 'RC-6bcddeab:16188c09983:-7f0b', 'FACTFLD-66032c9:16155c11111:-7dca', 'billtoyear', NULL, 'greater than', '>', '1', 'RCC-6bcddeab:16188c09983:-7f10', 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0a', 'RC-6bcddeab:16188c09983:-7f0b', 'FACTFLD5d750d7e:161889cc785:-7702', 'currentdate', 'CURRDATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0c', 'RC-6bcddeab:16188c09983:-7f0e', 'FACTFLD547c5381:1451ae1cd9c:-7970', 'lastqtrpaid', NULL, 'equal to', '==', '0', NULL, NULL, NULL, '4', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0d', 'RC-6bcddeab:16188c09983:-7f0e', 'FACTFLD547c5381:1451ae1cd9c:-797b', 'lastyearpaid', NULL, 'equal to', '==', '1', 'RCC-6bcddeab:16188c09983:-7f10', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f0f', 'RC-6bcddeab:16188c09983:-7f11', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7f10', 'RC-6bcddeab:16188c09983:-7f11', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC-6bcddeab:16188c09983:-7fd6', 'RC-6bcddeab:16188c09983:-7fd7', 'FACTFLD5d750d7e:161889cc785:-7702', 'currentdate', 'CDATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c67', 'RC13423d65:162270a87db:-7c69', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c68', 'RC13423d65:162270a87db:-7c69', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', 'greater than', '>', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c6a', 'RC13423d65:162270a87db:-7c6d', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', NULL, 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c6b', 'RC13423d65:162270a87db:-7c6d', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7c6c', 'RC13423d65:162270a87db:-7c6d', 'FACTFLD547c5381:1451ae1cd9c:-790d', 'qtr', NULL, 'greater than or equal to', '>=', '1', NULL, 'CQTR', NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7ccf', 'RC13423d65:162270a87db:-7cd0', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd1', 'RC13423d65:162270a87db:-7cd6', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '4');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd3', 'RC13423d65:162270a87db:-7cd6', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'less than', '<', '1', 'RCC13423d65:162270a87db:-7ccf', 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd4', 'RC13423d65:162270a87db:-7cd6', 'FACTFLD547c5381:1451ae1cd9c:-78a6', 'monthsfromjan', 'NMON', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '3');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13423d65:162270a87db:-7cd5', 'RC13423d65:162270a87db:-7cd6', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13524a8b:161b645b0bf:-7fde', 'RC13524a8b:161b645b0bf:-7fe0', 'FACTFLD-585c89e6:16156f39eeb:-7a07', 'qtrly', NULL, 'not true', '== false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13524a8b:161b645b0bf:-7fdf', 'RC13524a8b:161b645b0bf:-7fe0', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCC13524a8b:161b645b0bf:-7fe1', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC13524a8b:161b645b0bf:-7fe1', 'RC13524a8b:161b645b0bf:-7fe2', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC16a7ee38:15cfcd300fe:-7fb8', 'RC16a7ee38:15cfcd300fe:-7fba', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC16a7ee38:15cfcd300fe:-7fb9', 'RC16a7ee38:15cfcd300fe:-7fba', 'FACTFLD-39192c48:1471ebc2797:-7f3a', 'assessedvalue', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC16a7ee38:15cfcd300fe:-7fbb', 'RC16a7ee38:15cfcd300fe:-7fbc', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fb8', 'RC42bdb818:161e073d7b8:-7fba', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_ADVANCE\",value:\"RPT BASIC ADVANCE\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fb9', 'RC42bdb818:161e073d7b8:-7fba', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fbb', 'RC42bdb818:161e073d7b8:-7fbc', 'FACTFLD-78fba29f:161df51b937:-50ab', 'barangayid', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fc4', 'RC42bdb818:161e073d7b8:-7fc6', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASICINT_CURRENT\",value:\"RPT BASIC PENALTY CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fc5', 'RC42bdb818:161e073d7b8:-7fc6', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fc7', 'RC42bdb818:161e073d7b8:-7fc8', 'FACTFLD-78fba29f:161df51b937:-50ab', 'barangayid', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fd0', 'RC42bdb818:161e073d7b8:-7fd1', 'FACTFLD-78fba29f:161df51b937:-50ab', 'barangayid', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fd2', 'RC42bdb818:161e073d7b8:-7fd4', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fd3', 'RC42bdb818:161e073d7b8:-7fd4', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_CURRENT\",value:\"RPT BASIC CURRENT\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fe2', 'RC42bdb818:161e073d7b8:-7fe3', 'FACTFLD-78fba29f:161df51b937:-50ab', 'barangayid', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fe4', 'RC42bdb818:161e073d7b8:-7fe6', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fe5', 'RC42bdb818:161e073d7b8:-7fe6', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASICINT_PREVIOUS\",value:\"RPT BASIC PENALTY PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fee', 'RC42bdb818:161e073d7b8:-7ff0', 'FACTFLD-78fba29f:161df51b937:-7797', 'parentacctid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RPT_BASIC_PREVIOUS\",value:\"RPT BASIC PREVIOUS\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7fef', 'RC42bdb818:161e073d7b8:-7ff0', 'FACTFLD-78fba29f:161df51b937:-76cb', 'amount', 'AMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC42bdb818:161e073d7b8:-7ff1', 'RC42bdb818:161e073d7b8:-7ff2', 'FACTFLD-78fba29f:161df51b937:-50ab', 'barangayid', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7332', 'RC67caf065:1724e308e34:-7336', 'FACTFLD547c5381:1451ae1cd9c:-78a6', 'monthsfromjan', 'NMON', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '5');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7333', 'RC67caf065:1724e308e34:-7336', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '4');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7334', 'RC67caf065:1724e308e34:-7336', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7335', 'RC67caf065:1724e308e34:-7336', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCC67caf065:1724e308e34:-733a', 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7339', 'RC67caf065:1724e308e34:-733b', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', 'greater than', '>', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-733a', 'RC67caf065:1724e308e34:-733b', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7383', 'RC67caf065:1724e308e34:-7385', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7384', 'RC67caf065:1724e308e34:-7385', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', 'greater than', '>', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-7389', 'RC67caf065:1724e308e34:-738e', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCC67caf065:1724e308e34:-7383', 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-738a', 'RC67caf065:1724e308e34:-738e', 'FACTFLD547c5381:1451ae1cd9c:-790d', 'qtr', NULL, 'less than', '<', '1', 'RCC67caf065:1724e308e34:-7384', 'CQTR', NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-738c', 'RC67caf065:1724e308e34:-738e', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCC67caf065:1724e308e34:-738d', 'RC67caf065:1724e308e34:-738e', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '5');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-103fed47:146ffb40356:-7c7c', 'RCOND-103fed47:146ffb40356:-7d40', 'FACTFLD3e2b89cb:146ff734573:-7ed5', 'yrcompleted', 'YRCOMPLETED', 'greater than', '>', NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-103fed47:146ffb40356:-7ce5', 'RCOND-103fed47:146ffb40356:-7d40', 'FACTFLD3e2b89cb:146ff734573:-7ede', 'yrappraised', 'YRAPPRAISED', 'greater than', '>', NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2b45', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'FACTFLD-2486b0ca:146fff66c3e:-7b23', 'adjustment', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2b8c', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'FACTFLD-2486b0ca:146fff66c3e:-7b2c', 'depreciationvalue', 'DEP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-2bc5', 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'FACTFLD-2486b0ca:146fff66c3e:-7b35', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-382b', 'RCOND-2486b0ca:146fff66c3e:-3888', 'FACTFLD-2486b0ca:146fff66c3e:-7a60', 'adjustment', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-3860', 'RCOND-2486b0ca:146fff66c3e:-3888', 'FACTFLD-2486b0ca:146fff66c3e:-7a6b', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-3f19', 'RCOND-2486b0ca:146fff66c3e:-3f91', 'FACTFLD3e2b89cb:146ff734573:-7ea8', 'depreciation', 'DPRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-6a5a', 'RCOND-2486b0ca:146fff66c3e:-6aad', 'FACTFLD-2486b0ca:146fff66c3e:-7a76', 'unitvalue', 'UV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2486b0ca:146fff66c3e:-6a8b', 'RCOND-2486b0ca:146fff66c3e:-6aad', 'FACTFLD-2486b0ca:146fff66c3e:-7a99', 'area', 'AREA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-28dc975:156bcab666c:-5ed8', 'RCOND-28dc975:156bcab666c:-5f3d', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-28dc975:156bcab666c:-5f1b', 'RCOND-28dc975:156bcab666c:-5f3d', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"RP-28dc975:156bcab666c:-6a4d\",value:\"TOTALAV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-2ef3c345:147ed584975:-7e3d', 'RCOND-60c99d04:1470b276e7f:-7e2a', 'FACTFLD-2486b0ca:146fff66c3e:-7dc7', 'totalfloorarea', 'TOTALAREA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-332b', 'RCOND-46fca07e:14c545f3e6a:-3353', 'FACTFLD-2486b0ca:146fff66c3e:-7a6b', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-3481', 'RCOND-46fca07e:14c545f3e6a:-34b0', 'FACTFLD-2486b0ca:146fff66c3e:-7b35', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-7678', 'RCOND-46fca07e:14c545f3e6a:-7707', 'FACTFLD3afe51b9:146f7088d9c:-7d58', 'adjustment', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-76c6', 'RCOND-46fca07e:14c545f3e6a:-7707', 'FACTFLD3afe51b9:146f7088d9c:-7d61', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-77f2', 'RCOND-46fca07e:14c545f3e6a:-786f', 'FACTFLD3afe51b9:146f7088d9c:-7d73', 'unitvalue', 'UV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-46fca07e:14c545f3e6a:-783a', 'RCOND-46fca07e:14c545f3e6a:-786f', 'FACTFLD-46fca07e:14c545f3e6a:-79a6', 'area', 'AREA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-4b89dc91:161211998d3:3e8d', 'RC16a7ee38:15cfcd300fe:-7fba', 'FACTFLD29e16c33:156249fdf8e:-6e66', 'taxable', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-585c89e6:16156f39eeb:-74ab', 'RCOND-585c89e6:16156f39eeb:-7586', 'FACTFLD-585c89e6:16156f39eeb:-7a07', 'qtrly', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-585c89e6:16156f39eeb:-753d', 'RCOND-585c89e6:16156f39eeb:-7586', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'less than', '<', '1', 'RCONST-585c89e6:16156f39eeb:-75f5', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-585c89e6:16156f39eeb:-75f5', 'RCOND-585c89e6:16156f39eeb:-760c', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-59249a93:1614f57bd58:-7d27', 'RCOND-59249a93:1614f57bd58:-7d29', 'FACTFLD-5ed6c5b0:16145892be0:-7d6b', 'av', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-59249a93:1614f57bd58:-7d28', 'RCOND-59249a93:1614f57bd58:-7d29', 'FACTFLD-5ed6c5b0:16145892be0:-7d74', 'year', 'YR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6f25', 'RCOND-5e76cf73:14d69e9c549:-701c', 'FACTFLD3afe51b9:146f7088d9c:-7d46', 'actualuseadjustment', 'AUADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6f83', 'RCOND-5e76cf73:14d69e9c549:-701c', 'FACTFLD3afe51b9:146f7088d9c:-7d4f', 'landvalueadjustment', 'LVADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-6fd3', 'RCOND-5e76cf73:14d69e9c549:-701c', 'FACTFLD3afe51b9:146f7088d9c:-7d58', 'adjustment', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-5e76cf73:14d69e9c549:-7e44', 'RCOND-5e76cf73:14d69e9c549:-7e5d', 'FACTFLD-5e76cf73:14d69e9c549:-7ed2', 'adjustment', 'ADJAMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-60c99d04:1470b276e7f:-7d64', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'FACTFLD-2486b0ca:146fff66c3e:-7b47', 'basevalue', 'BASEVALUE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-60c99d04:1470b276e7f:-7dae', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'FACTFLD-2486b0ca:146fff66c3e:-7b50', 'bldgstructure', NULL, 'equals', '==', NULL, 'RCOND-60c99d04:1470b276e7f:-7e2a', 'BS', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-621d5f20:16222e9bf6d:-2457', 'RCOND5b84d618:1615428187f:-677a', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', 'equal to', '==', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-6c4ec747:154bd626092:-5554', 'RCOND-6c4ec747:154bd626092:-55c3', 'FACTFLD-6c4ec747:154bd626092:-5693', 'swornamount', 'SWORNAMT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-6c4ec747:154bd626092:-558e', 'RCOND-6c4ec747:154bd626092:-55c3', 'FACTFLD-6c4ec747:154bd626092:-5677', 'useswornamount', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-6d782e97:161e4c91fda:-31e8', 'RC13524a8b:161b645b0bf:-7fe0', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-59dc', 'RCOND-762e9176:15d067a9c42:-5a4b', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'TOTALAV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5a2a', 'RCOND-762e9176:15d067a9c42:-5a4b', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"P-79a9a347:15cfcae84de:-5edb\",value:\"TOTAL_AV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5d1b', 'RCOND-762e9176:15d067a9c42:-5d56', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5da3', 'RCOND-762e9176:15d067a9c42:-5dd2', 'FACTFLD-39192c48:1471ebc2797:-7f3a', 'assessedvalue', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-762e9176:15d067a9c42:-5dd1', 'RCOND-762e9176:15d067a9c42:-5dd2', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-1dd7', 'RCOND-79a9a347:15cfcae84de:-1e48', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'TOTALAV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-1e27', 'RCOND-79a9a347:15cfcae84de:-1e48', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"P-79a9a347:15cfcae84de:-5edb\",value:\"TOTAL_AV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-20b9', 'RCOND-79a9a347:15cfcae84de:-20e8', 'FACTFLD-39192c48:1471ebc2797:-7f3a', 'assessedvalue', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-20e7', 'RCOND-79a9a347:15cfcae84de:-20e8', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-5a45', 'RCOND-79a9a347:15cfcae84de:-5af4', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-5aaa', 'RCOND-79a9a347:15cfcae84de:-5af4', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"P-79a9a347:15cfcae84de:-5edb\",value:\"TOTAL_AV\"]]', NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-5ccd', 'RCOND-79a9a347:15cfcae84de:-6ebc', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-61bf', 'RCOND-79a9a347:15cfcae84de:-6222', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-625', 'RCOND-79a9a347:15cfcae84de:-928', 'FACTFLD-79a9a347:15cfcae84de:-754', 'assesslevel', 'AL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '3');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-62a7', 'RCOND-79a9a347:15cfcae84de:-637a', 'FACTFLD-39192c48:1471ebc2797:-7f3a', 'assessedvalue', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-6379', 'RCOND-79a9a347:15cfcae84de:-637a', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-858', 'RCOND-79a9a347:15cfcae84de:-928', 'FACTFLD1e772168:14c5a447e35:-7f50', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-8ad', 'RCOND-79a9a347:15cfcae84de:-928', 'FACTFLD16890479:155dcd2ec4e:-7dd1', 'taxable', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-8fd', 'RCOND-79a9a347:15cfcae84de:-928', 'FACTFLD1e772168:14c5a447e35:-7f62', 'machuse', NULL, 'equals', '==', NULL, 'RCOND-79a9a347:15cfcae84de:-a77', 'MAU', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:-c0a', 'RCOND-79a9a347:15cfcae84de:-c6d', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:1012', 'RCOND-79a9a347:15cfcae84de:fb4', 'FACTFLD6b62feef:14c53ac1f59:-7ed7', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:1089', 'RCOND-79a9a347:15cfcae84de:fb4', 'FACTFLD6b62feef:14c53ac1f59:-7ece', 'assesslevel', 'AL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:4fce', 'RCOND-79a9a347:15cfcae84de:4fcd', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:4ffe', 'RCOND-79a9a347:15cfcae84de:4fcd', 'FACTFLD-39192c48:1471ebc2797:-7f3a', 'assessedvalue', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:50f0', 'RCOND-79a9a347:15cfcae84de:508d', 'FACTFLD-28dc975:156bcab666c:-6789', 'objid', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:5606', 'RCOND-79a9a347:15cfcae84de:55ab', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"P-79a9a347:15cfcae84de:-5edb\",value:\"TOTAL_AV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-79a9a347:15cfcae84de:5657', 'RCOND-79a9a347:15cfcae84de:55ab', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'TOTALAV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-7deff7e5:161b60a3048:-5d4f', 'RCOND3de2e0bf:15165926561:-7bb4', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', NULL, 'greater than', '>', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-a35dd35:14e51ec3311:-5cc7', 'RCOND-a35dd35:14e51ec3311:-5d14', 'FACTFLD-a35dd35:14e51ec3311:-608a', 'swornamount', 'SWORNAMT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST-a35dd35:14e51ec3311:-5cf0', 'RCOND-a35dd35:14e51ec3311:-5d14', 'FACTFLD-a35dd35:14e51ec3311:-6104', 'useswornamount', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST102ab3e1:147190e9fe4:-26f3', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'FACTFLD-2486b0ca:146fff66c3e:-7b23', 'adjustment', 'ADJUSTMENT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST102ab3e1:147190e9fe4:-272e', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'FACTFLD-2486b0ca:146fff66c3e:-7b35', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1441128c:1471efa4c1c:-6c2e', 'RCOND1441128c:1471efa4c1c:-6c2f', 'FACTFLD-39192c48:1471ebc2797:-7f95', 'actualuseid', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1441128c:1471efa4c1c:-6d47', 'RCOND1441128c:1471efa4c1c:-6d84', 'FACTFLD1441128c:1471efa4c1c:-6de2', 'actualuseid', 'ACTUALUSE', 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST17007256:15f8f890d04:-7ca2', 'RCOND3de2e0bf:15165926561:-7b18', 'FACTFLD17007256:15f8f890d04:-7dae', 'qtrly', NULL, 'not true', '== false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1b4af871:14e3cc46e09:-2f4b', 'RCOND1b4af871:14e3cc46e09:-2fc5', 'FACTFLD59614e16:14c5e56ecc8:-7fa5', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1b4af871:14e3cc46e09:-31dc', 'RCOND1b4af871:14e3cc46e09:-31fc', 'FACTFLD59614e16:14c5e56ecc8:-7fbb', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-65a1', 'RCOND1e772168:14c5a447e35:-65bc', 'FACTFLD1e772168:14c5a447e35:-662f', 'depreciationvalue', 'DEP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-6ce4', 'RCOND1e772168:14c5a447e35:-6cfc', 'FACTFLD1e772168:14c5a447e35:-7f50', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e772168:14c5a447e35:-7db8', 'RCOND1e772168:14c5a447e35:-7dce', 'FACTFLD1e772168:14c5a447e35:-7f59', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:311', 'RCOND1e983c10:147f2149816:2ff', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:3b6', 'RCOND1e983c10:147f2149816:373', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'less than', '<', '1', 'RCONST1e983c10:147f2149816:311', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:48b', 'RCOND1e983c10:147f2149816:479', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:522', 'RCOND1e983c10:147f2149816:4df', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCONST1e983c10:147f2149816:48b', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:621', 'RCOND1e983c10:147f2149816:60f', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1e983c10:147f2149816:6b8', 'RCOND1e983c10:147f2149816:675', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'greater than', '>', '1', 'RCONST1e983c10:147f2149816:621', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST1ff29cd0:1572617f8d8:-7d08', 'RCOND1ff29cd0:1572617f8d8:-7d30', 'FACTFLD59614e16:14c5e56ecc8:-7ea9', 'depreciation', 'DPRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST37df8403:14c5405fff0:-7656', 'RCOND37df8403:14c5405fff0:-7693', 'FACTFLD6b62feef:14c53ac1f59:-7ef2', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-6160', 'RCOND3b800abe:14d2b978f55:-6196', 'FACTFLD-2486b0ca:146fff66c3e:-7b1a', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-630b', 'RCOND3b800abe:14d2b978f55:-6339', 'FACTFLD-2486b0ca:146fff66c3e:-7a55', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-7cdb', 'RCOND3b800abe:14d2b978f55:-7d69', 'FACTFLD-2486b0ca:146fff66c3e:-70e6', 'amount', 'ADJAMOUNT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3b800abe:14d2b978f55:-7d68', 'RCOND3b800abe:14d2b978f55:-7d69', 'FACTFLD-2486b0ca:146fff66c3e:-7104', 'bldgfloor', NULL, 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3de2e0bf:15165926561:-7aad', 'RCOND3de2e0bf:15165926561:-7b18', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'greater than or equal to', '>=', '1', 'RCONST3de2e0bf:15165926561:-7ba2', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3de2e0bf:15165926561:-7ba2', 'RCOND3de2e0bf:15165926561:-7bb4', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3fb43b91:14ccf782188:-5f2b', 'RCOND3fb43b91:14ccf782188:-5fd2', 'FACTFLD6b62feef:14c53ac1f59:-7ee0', 'adjustmentrate', 'ADJRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST3fb43b91:14ccf782188:-5f95', 'RCOND3fb43b91:14ccf782188:-5fd2', 'FACTFLD6b62feef:14c53ac1f59:-7ef2', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST40c0977:151a9b0cb60:-7d29', 'RCOND-60c99d04:1470b276e7f:-7dd3', 'FACTFLD-2486b0ca:146fff66c3e:-7b3e', 'area', 'BUAREA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-67ae', 'RCOND1b4af871:14e3cc46e09:-2fe8', 'FACTFLD49a3c540:14e51feb8f6:-6cc5', 'objid', 'REFID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-6bc7', 'RCOND1b4af871:14e3cc46e09:-3242', 'FACTFLD49a3c540:14e51feb8f6:-6cc5', 'objid', 'REFID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-769e', 'RCOND49a3c540:14e51feb8f6:-76da', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'TOTALMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-76c7', 'RCOND49a3c540:14e51feb8f6:-76da', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"TOTAL_MV\",value:\"TOTAL_MV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-7712', 'RCOND49a3c540:14e51feb8f6:-774e', 'FACTFLD1b4af871:14e3cc46e09:-3491', 'value', 'TOTALBMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-773b', 'RCOND49a3c540:14e51feb8f6:-774e', 'FACTFLD1b4af871:14e3cc46e09:-34a2', 'varid', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[[key:\"TOTAL_BMV\",value:\"TOTAL_BMV\"]]', NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST49a3c540:14e51feb8f6:-7776', 'RCOND49a3c540:14e51feb8f6:-779a', 'FACTFLD-a35dd35:14e51ec3311:-6104', 'useswornamount', NULL, 'not true', '== false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4bf973aa:1562a233196:-4d8d', 'RCOND4bf973aa:1562a233196:-500e', 'FACTFLD4bf973aa:1562a233196:-4e2d', 'depreciation', 'DEPRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4bf973aa:1562a233196:-4f3a', 'RCOND4bf973aa:1562a233196:-500e', 'FACTFLD-6c4ec747:154bd626092:-5677', 'useswornamount', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4bf973aa:1562a233196:-4f81', 'RCOND4bf973aa:1562a233196:-500e', 'FACTFLD-6c4ec747:154bd626092:-5693', 'swornamount', 'SWORNAMT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7919', 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'FACTFLD-66ddf216:14f92338db7:-797f', 'useswornamount', NULL, 'not true', '== false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7a21', 'RCOND4e46261d:14f924c6b53:-7c57', 'FACTFLD-66ddf216:14f92338db7:-797f', 'useswornamount', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7bc5', 'RCOND4e46261d:14f924c6b53:-7c57', 'FACTFLD-2486b0ca:146fff66c3e:-7b23', 'adjustment', 'ADJUSTMENT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7c0e', 'RCOND4e46261d:14f924c6b53:-7c57', 'FACTFLD-66ddf216:14f92338db7:-798a', 'swornamount', 'SWORNAMT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4e46261d:14f924c6b53:-7cc1', 'RCOND4e46261d:14f924c6b53:-7d37', 'FACTFLD3e2b89cb:146ff734573:-7ea8', 'depreciation', 'DPRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4fc9c2c7:176cac860ed:-752d', 'RCOND4fc9c2c7:176cac860ed:-75f6', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4fc9c2c7:176cac860ed:-75ac', 'RCOND4fc9c2c7:176cac860ed:-75f6', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCONST4fc9c2c7:176cac860ed:-7674', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST4fc9c2c7:176cac860ed:-7674', 'RCOND4fc9c2c7:176cac860ed:-768b', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST528b640a:1615a0f2b5b:-7cc8', 'RCOND3de2e0bf:15165926561:-7b18', 'FACTFLD-585c89e6:16156f39eeb:-7a07', 'qtrly', NULL, 'not true', '== false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7c46', 'RCOND59614e16:14c5e56ecc8:-7c8f', 'FACTFLD59614e16:14c5e56ecc8:-7fb0', 'depreciatedvalue', 'DEP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7c6f', 'RCOND59614e16:14c5e56ecc8:-7c8f', 'FACTFLD59614e16:14c5e56ecc8:-7fbb', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7d8b', 'RCOND59614e16:14c5e56ecc8:-7dcb', 'FACTFLD59614e16:14c5e56ecc8:-7ea9', 'depreciation', 'DEPRATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST59614e16:14c5e56ecc8:-7db3', 'RCOND59614e16:14c5e56ecc8:-7dcb', 'FACTFLD59614e16:14c5e56ecc8:-7fbb', 'basemarketvalue', 'BMV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5a030c2b:17277b1ddc5:-7d66', 'RCOND5a030c2b:17277b1ddc5:-7e0f', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'less than or equal to', '<=', NULL, NULL, NULL, NULL, '2018', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5a030c2b:17277b1ddc5:-7dc6', 'RCOND5a030c2b:17277b1ddc5:-7e0f', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'greater than or equal to', '>=', NULL, NULL, NULL, NULL, '2015', NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b4ac915:147baaa06b4:-6d59', 'RCOND5b4ac915:147baaa06b4:-6da4', 'FACTFLD5b4ac915:147baaa06b4:-6e01', 'classification', 'CLASS', 'not null', '!= null', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6159', 'RCOND5b84d618:1615428187f:-622b', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-61e4', 'RCOND5b84d618:1615428187f:-622b', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'greater than', '>', '1', 'RCONST5b84d618:1615428187f:-628c', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-628c', 'RCOND5b84d618:1615428187f:-62a3', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6624', 'RCOND5b84d618:1615428187f:-66fa', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-66b3', 'RCOND5b84d618:1615428187f:-66fa', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCONST5b84d618:1615428187f:-6763', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5b84d618:1615428187f:-6763', 'RCOND5b84d618:1615428187f:-677a', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-6b94', 'RCOND5d750d7e:161889cc785:-6f08', 'FACTFLD-66032c9:16155c11111:-7dca', 'billtoyear', NULL, 'equal to', '==', '1', 'RCONST5d750d7e:161889cc785:-7124', 'CY', NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-6e27', 'RCOND5d750d7e:161889cc785:-6f08', 'FACTFLD5d750d7e:161889cc785:-7702', 'currentdate', 'CURRDATE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-6fd3', 'RCOND5d750d7e:161889cc785:-7066', 'FACTFLD547c5381:1451ae1cd9c:-7970', 'lastqtrpaid', 'LAST_QTR_PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-7029', 'RCOND5d750d7e:161889cc785:-7066', 'FACTFLD547c5381:1451ae1cd9c:-797b', 'lastyearpaid', 'LAST_YR_PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-70ee', 'RCOND5d750d7e:161889cc785:-713b', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', 'CQTR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST5d750d7e:161889cc785:-7124', 'RCOND5d750d7e:161889cc785:-713b', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST634d9a3c:161503ff1dc:-580e', 'RCOND634d9a3c:161503ff1dc:-586c', 'FACTFLD547c5381:1451ae1cd9c:-78fb', 'av', 'AV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST650f832b:14c53e6ce93:-795e', 'RCOND650f832b:14c53e6ce93:-79a1', 'FACTFLD6b62feef:14c53ac1f59:-7ed7', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-5e5f', 'RCOND6afb50c:1724e644945:-5f45', 'FACTFLD547c5381:1451ae1cd9c:-77a1', 'amtdue', 'TAX', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-5f02', 'RCOND6afb50c:1724e644945:-5f45', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCONST6afb50c:1724e644945:-5fd7', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-5fd7', 'RCOND6afb50c:1724e644945:-5fea', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-6101', 'RCOND6afb50c:1724e644945:-6144', 'FACTFLD547c5381:1451ae1cd9c:-7916', 'year', NULL, 'equal to', '==', '1', 'RCONST6afb50c:1724e644945:-6295', 'CY', NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-6189', 'RCOND6afb50c:1724e644945:-61d4', 'FACTFLD603bde10:15e028ba480:-7d9f', 'missedpayment', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-625f', 'RCOND6afb50c:1724e644945:-62a7', 'FACTFLD49ae4bad:141e3b6758c:-7b95', 'qtr', NULL, 'greater than', '>', NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-6295', 'RCOND6afb50c:1724e644945:-62a7', 'FACTFLD49ae4bad:141e3b6758c:-7b9c', 'year', 'CY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-63fd', 'RC67caf065:1724e308e34:-7338', 'FACTFLD603bde10:15e028ba480:-7d9f', 'missedpayment', NULL, 'is true', '== true', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6afb50c:1724e644945:-69fd', 'RC67caf065:1724e308e34:-738e', 'FACTFLD547c5381:1451ae1cd9c:-78a6', 'monthsfromjan', 'NMON', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '6');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6d174068:14e3de9c20b:-7f46', 'RCOND6d174068:14e3de9c20b:-7f93', 'FACTFLD1b4af871:14e3cc46e09:-364b', 'assesslevel', 'AL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST6d174068:14e3de9c20b:-7f73', 'RCOND6d174068:14e3de9c20b:-7f93', 'FACTFLD1b4af871:14e3cc46e09:-3654', 'marketvalue', 'MV', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-1ec6', 'RC-293918d4:16209768e19:-7f8d', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-206e', 'RC-293918d4:16209768e19:-7f7b', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2218', 'RC-293918d4:16209768e19:-7f6f', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-23c0', 'RC-293918d4:16209768e19:-7f66', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2568', 'RC-293918d4:16209768e19:-7f5a', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2710', 'RC-293918d4:16209768e19:-7f48', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-28b8', 'RC-293918d4:16209768e19:-7f33', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2a60', 'RC-293918d4:16209768e19:-7f2a', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2c08', 'RC-293918d4:16209768e19:-7f1b', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST713e35a1:1620963487c:-2da6', 'RC-293918d4:16209768e19:-7f0c', 'FACTFLD-78fba29f:161df51b937:-42de', 'parentlguid', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST7c3b2c58:1619d761d9d:-6592', 'RCOND3de2e0bf:15165926561:-7b18', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '2');
REPLACE INTO `sys_rule_condition_constraint` (`objid`, `parentid`, `field_objid`, `fieldname`, `varname`, `operator_caption`, `operator_symbol`, `usevar`, `var_objid`, `var_name`, `decimalvalue`, `intvalue`, `stringvalue`, `listvalue`, `datevalue`, `pos`) VALUES ('RCONST7c3b2c58:1619d761d9d:-7bbe', 'RCOND634d9a3c:161503ff1dc:-586c', 'FACTFLD634d9a3c:161503ff1dc:-7628', 'revtype', NULL, 'is any of the ff.', 'matches', NULL, NULL, NULL, NULL, NULL, NULL, '[\"basic\",\"sef\"]', NULL, '1');

REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-15f7fe9f:15cf6ec9fa5:-7fbf', 'RUL-31fc82f2:15cf6ecbe4d:-6b3d', 'RULADEF-128a4cad:146f96a678e:-7efa', 'calc-av', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f0a', 'RUL713e35a1:1620963487c:-54ee', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f16', 'RUL713e35a1:1620963487c:-5520', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f25', 'RUL713e35a1:1620963487c:-5552', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f31', 'RUL713e35a1:1620963487c:-5584', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f46', 'RUL713e35a1:1620963487c:-583b', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f55', 'RUL713e35a1:1620963487c:-588e', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f61', 'RUL713e35a1:1620963487c:-58d7', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f6d', 'RUL713e35a1:1620963487c:-5939', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f79', 'RUL713e35a1:1620963487c:-5972', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-293918d4:16209768e19:-7f88', 'RUL713e35a1:1620963487c:-59d5', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-69b5f604:15cfc6b3e74:-7e36', 'RUL-79a9a347:15cfcae84de:-707b', 'RULADEF1441128c:1471efa4c1c:-69a5', 'calc-assess-value', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-6bcddeab:16188c09983:-7edc', 'RUL5d750d7e:161889cc785:-5f54', 'RULADEF5d750d7e:161889cc785:-7d47', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA-6bcddeab:16188c09983:-7fd5', 'RUL5d750d7e:161889cc785:-72c0', 'RULADEF5d750d7e:161889cc785:-7d47', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA13423d65:162270a87db:-7c66', 'RUL-621d5f20:16222e9bf6d:-bc0', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA13423d65:162270a87db:-7cce', 'RUL-621d5f20:16222e9bf6d:-19d5', 'RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA13524a8b:161b645b0bf:-7fdd', 'RUL-7deff7e5:161b60a3048:-5a7e', 'RULADEF-66032c9:16155c11111:-7c6a', 'split-bill-item', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA16a7ee38:15cfcd300fe:-7fb7', 'RUL-79a9a347:15cfcae84de:-55fd', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA67caf065:1724e308e34:-7331', 'RUL6afb50c:1724e644945:-6621', 'RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RA67caf065:1724e308e34:-7382', 'RUL6afb50c:1724e644945:-6b4e', 'RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-103fed47:146ffb40356:-7c51', 'RUL3e2b89cb:146ff734573:-7dcc', 'RULADEF3e2b89cb:146ff734573:-7c47', 'calc-bldg-age', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-13574fd2:1621b509f0b:-7134', 'RUL-2486b0ca:146fff66c3e:-4697', 'RULADEF36885e11:150188b0d78:-7e0c', 'calc-depreciation-range', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-2486b0ca:146fff66c3e:-2ade', 'RUL-2486b0ca:146fff66c3e:-2c4a', 'RULADEF-2486b0ca:146fff66c3e:-3151', 'calc-bldguse-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-2486b0ca:146fff66c3e:-37a2', 'RUL-2486b0ca:146fff66c3e:-38e4', 'RULADEF-2486b0ca:146fff66c3e:-79a8', 'calc-floor-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-2486b0ca:146fff66c3e:-3d32', 'RUL-2486b0ca:146fff66c3e:-4192', 'RULADEF-2486b0ca:146fff66c3e:-4365', 'calc-bldguse-depreciation', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-2486b0ca:146fff66c3e:-6a12', 'RUL-2486b0ca:146fff66c3e:-6b05', 'RULADEF-2486b0ca:146fff66c3e:-7a02', 'calc-floor-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-28dc975:156bcab666c:-5e3c', 'RUL-3e8edbea:156bc08656a:-5f05', 'RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-46fca07e:14c545f3e6a:-32d0', 'RUL-46fca07e:14c545f3e6a:-33b4', 'RULADEF-2486b0ca:146fff66c3e:-7a02', 'calc-floor-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-46fca07e:14c545f3e6a:-3422', 'RUL-46fca07e:14c545f3e6a:-350f', 'RULADEF-60c99d04:1470b276e7f:-7c52', 'calc-bldguse-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-46fca07e:14c545f3e6a:-763d', 'RUL-46fca07e:14c545f3e6a:-7740', 'RULADEF-21ad68c1:146fc2282bb:-7b6e', 'calc-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-46fca07e:14c545f3e6a:-77ba', 'RUL-46fca07e:14c545f3e6a:-7a8b', 'RULADEF3afe51b9:146f7088d9c:-7c7b', 'calc-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-585c89e6:16156f39eeb:-7427', 'RUL-585c89e6:16156f39eeb:-770f', 'RULADEF-585c89e6:16156f39eeb:-77aa', 'aggregate-bill-item', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-5e76cf73:14d69e9c549:-6e13', 'RUL-5e76cf73:14d69e9c549:-7084', 'RULADEF-5e76cf73:14d69e9c549:-72c3', 'update-landdetail-adj', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-5e76cf73:14d69e9c549:-6e73', 'RUL-5e76cf73:14d69e9c549:-7084', 'RULADEF-5e76cf73:14d69e9c549:-7232', 'update-landdetail-actualuse-adj', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-5e76cf73:14d69e9c549:-6ece', 'RUL-5e76cf73:14d69e9c549:-7084', 'RULADEF-5e76cf73:14d69e9c549:-71e7', 'update-landdetail-adj', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-5e76cf73:14d69e9c549:-7d14', 'RUL-5e76cf73:14d69e9c549:-7fd4', 'RULADEF-5e76cf73:14d69e9c549:-7e09', 'update-adj', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-60c99d04:1470b276e7f:-7a52', 'RUL-60c99d04:1470b276e7f:-7ecc', 'RULADEF-60c99d04:1470b276e7f:-7c52', 'calc-bldguse-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-6c4ec747:154bd626092:-444a', 'RUL-6c4ec747:154bd626092:-5616', 'RULADEF1e772168:14c5a447e35:-7eaf', 'calc-mach-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-6c4ec747:154bd626092:-54b9', 'RUL-6c4ec747:154bd626092:-5616', 'RULADEF1e772168:14c5a447e35:-7ed1', 'calc-mach-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-762e9176:15d067a9c42:-58a6', 'RUL-762e9176:15d067a9c42:-5aa0', 'RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-762e9176:15d067a9c42:-5b22', 'RUL-762e9176:15d067a9c42:-5e26', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-78fba29f:161df51b937:-70ed', 'RUL-78fba29f:161df51b937:-74da', 'RULADEF-78fba29f:161df51b937:-7568', 'add-billitem', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:-1c9a', 'RUL-79a9a347:15cfcae84de:-1ed3', 'RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:-1f45', 'RUL-79a9a347:15cfcae84de:-2167', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:-527', 'RUL-79a9a347:15cfcae84de:-b33', 'RULADEF1e772168:14c5a447e35:-7e28', 'calc-mach-av', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:-5e1c', 'RUL-79a9a347:15cfcae84de:-6401', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:-6d86', 'RUL-79a9a347:15cfcae84de:-6f2a', 'RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:1100', 'RUL-79a9a347:15cfcae84de:f6c', 'RULADEF6b62feef:14c53ac1f59:-7e2c', 'calc-planttree-av', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:514e', 'RUL-79a9a347:15cfcae84de:4f83', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-79a9a347:15cfcae84de:56d7', 'RUL-79a9a347:15cfcae84de:549e', 'RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-7deff7e5:161b60a3048:-6f2e', 'RUL5d750d7e:161889cc785:-7301', 'RULADEF-7deff7e5:161b60a3048:-7212', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-7deff7e5:161b60a3048:-6fe3', 'RUL5d750d7e:161889cc785:-72c0', 'RULADEF-7deff7e5:161b60a3048:-7212', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-7deff7e5:161b60a3048:-708e', 'RUL5d750d7e:161889cc785:-61f2', 'RULADEF-7deff7e5:161b60a3048:-7212', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-7deff7e5:161b60a3048:-7169', 'RUL5d750d7e:161889cc785:-5f54', 'RULADEF-7deff7e5:161b60a3048:-7212', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-a35dd35:14e51ec3311:-5c1b', 'RUL-a35dd35:14e51ec3311:-5d4c', 'RULADEF1b4af871:14e3cc46e09:-35cc', 'calc-rpu-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT-a35dd35:14e51ec3311:-5c77', 'RUL-a35dd35:14e51ec3311:-5d4c', 'RULADEF1b4af871:14e3cc46e09:-3612', 'calc-rpu-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1441128c:1471efa4c1c:-6b97', 'RUL1441128c:1471efa4c1c:-6c93', 'RULADEF-39192c48:1471ebc2797:-7dae', 'calc-assess-level', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1441128c:1471efa4c1c:-6ce7', 'RUL1441128c:1471efa4c1c:-6eaa', 'RULADEF-39192c48:1471ebc2797:-7dee', 'add-assessment-info', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT17570bc8:16168d77d6c:-64b1', 'RUL1e983c10:147f2149816:5a3', 'RULADEF1be07afa:1452a9809e9:-6958', 'create-tax-summary', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT17570bc8:16168d77d6c:-65d4', 'RUL1e983c10:147f2149816:2bc', 'RULADEF1be07afa:1452a9809e9:-6958', 'create-tax-summary', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT17570bc8:16168d77d6c:-66b6', 'RUL1e983c10:147f2149816:437', 'RULADEF1be07afa:1452a9809e9:-6958', 'create-tax-summary', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1b4af871:14e3cc46e09:-2ef1', 'RUL1b4af871:14e3cc46e09:-301e', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1b4af871:14e3cc46e09:-3191', 'RUL1b4af871:14e3cc46e09:-3341', 'RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1e772168:14c5a447e35:-6572', 'RUL1e772168:14c5a447e35:-669c', 'RULADEF1e772168:14c5a447e35:-6703', 'calc-mach-depreciation', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1e772168:14c5a447e35:-6cba', 'RUL1e772168:14c5a447e35:-6d2f', 'RULADEF1e772168:14c5a447e35:-7eaf', 'calc-mach-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1e772168:14c5a447e35:-7d92', 'RUL1e772168:14c5a447e35:-7e01', 'RULADEF1e772168:14c5a447e35:-7ed1', 'calc-mach-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1ef00448:161e1e4995a:-4f85', 'RUL-78fba29f:161df51b937:-4bf1', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1ef00448:161e1e4995a:-5072', 'RUL-78fba29f:161df51b937:-4b72', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1ef00448:161e1e4995a:-519b', 'RUL-78fba29f:161df51b937:-4a59', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1ef00448:161e1e4995a:-5288', 'RUL-78fba29f:161df51b937:-4951', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT1ef00448:161e1e4995a:-5388', 'RUL-78fba29f:161df51b937:-4837', 'RULADEF-78fba29f:161df51b937:-7089', 'add-share', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT37df8403:14c5405fff0:-762e', 'RUL37df8403:14c5405fff0:-76bf', 'RULADEF6b62feef:14c53ac1f59:-7ea2', 'calc-planttree-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT3b800abe:14d2b978f55:-60fe', 'RUL3b800abe:14d2b978f55:-61fb', 'RULADEF-2486b0ca:146fff66c3e:-3151', 'calc-bldguse-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT3b800abe:14d2b978f55:-627d', 'RUL3b800abe:14d2b978f55:-63a0', 'RULADEF-2486b0ca:146fff66c3e:-79a8', 'calc-floor-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT3b800abe:14d2b978f55:-7c65', 'RUL3b800abe:14d2b978f55:-7e09', 'RULADEF-2486b0ca:146fff66c3e:-723b', 'calc-adj', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT3de2e0bf:15165926561:-7a68', 'RUL3de2e0bf:15165926561:-7bfc', 'RULADEF1fcd83ed:149bc7d0f75:-7d4b', 'split-by-qtr', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT3fb43b91:14ccf782188:-5ed3', 'RUL3fb43b91:14ccf782188:-6008', 'RULADEF6b62feef:14c53ac1f59:-7e83', 'calc-planttree-adjustment', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT49a3c540:14e51feb8f6:-75ac', 'RUL49a3c540:14e51feb8f6:-77d2', 'RULADEF1b4af871:14e3cc46e09:-35cc', 'calc-rpu-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT49a3c540:14e51feb8f6:-7610', 'RUL49a3c540:14e51feb8f6:-77d2', 'RULADEF1b4af871:14e3cc46e09:-3612', 'calc-rpu-bmv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT4bf973aa:1562a233196:-4d26', 'RUL4bf973aa:1562a233196:-5055', 'RULADEF1e772168:14c5a447e35:-6703', 'calc-mach-depreciation', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT4e46261d:14f924c6b53:-7b49', 'RUL4e46261d:14f924c6b53:-7d9b', 'RULADEF-2486b0ca:146fff66c3e:-4365', 'calc-bldguse-depreciation', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT4fc9c2c7:176cac860ed:-74b0', 'RUL4fc9c2c7:176cac860ed:-76d7', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5022d8ba:1589ae965a4:-7a42', 'RUL5022d8ba:1589ae965a4:-7c9c', 'RULADEF5022d8ba:1589ae965a4:-7b0e', 'add-planttree-assessment-info', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT59614e16:14c5e56ecc8:-7c0c', 'RUL59614e16:14c5e56ecc8:-7cbf', 'RULADEF59614e16:14c5e56ecc8:-7f1c', 'calc-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT59614e16:14c5e56ecc8:-7d53', 'RUL59614e16:14c5e56ecc8:-7dfb', 'RULADEF59614e16:14c5e56ecc8:-7f42', 'calc-depreciation', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5a030c2b:17277b1ddc5:-7cee', 'RUL5a030c2b:17277b1ddc5:-7e65', 'RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5b4ac915:147baaa06b4:-6be9', 'RUL5b4ac915:147baaa06b4:-6f31', 'RULADEF5b4ac915:147baaa06b4:-7dbe', 'add-assessment-info', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5b84d618:1615428187f:-60db', 'RUL5b84d618:1615428187f:-62e3', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5b84d618:1615428187f:-658c', 'RUL5b84d618:1615428187f:-67ce', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5d750d7e:161889cc785:-5fbe', 'RUL5d750d7e:161889cc785:-61f2', 'RULADEF5d750d7e:161889cc785:-7d47', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT5d750d7e:161889cc785:-6d93', 'RUL5d750d7e:161889cc785:-7301', 'RULADEF5d750d7e:161889cc785:-7d47', 'set-bill-expiry', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT634d9a3c:161503ff1dc:-57c7', 'RUL634d9a3c:161503ff1dc:-5b2a', 'RULADEF634d9a3c:161503ff1dc:-787a', 'calc-tax', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT634d9a3c:161503ff1dc:-5b7d', 'RUL-59249a93:1614f57bd58:-7d49', 'RULADEF-5ed6c5b0:16145892be0:-6988', 'add-sef', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT634d9a3c:161503ff1dc:-5bdb', 'RUL-59249a93:1614f57bd58:-7d49', 'RULADEF-5ed6c5b0:16145892be0:-7d18', 'add-basic', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT650f832b:14c53e6ce93:-7930', 'RUL650f832b:14c53e6ce93:-79cd', 'RULADEF6b62feef:14c53ac1f59:-7e59', 'calc-planttree-mv', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT6afb50c:1724e644945:-5d7c', 'RUL6afb50c:1724e644945:-602d', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT6afb50c:1724e644945:-5de8', 'RUL6afb50c:1724e644945:-602d', 'RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT6afb50c:1724e644945:-608a', 'RUL6afb50c:1724e644945:-62f2', 'RULADEF5b84d618:1615428187f:-6904', 'calc-discount', '0');
REPLACE INTO `sys_rule_action` (`objid`, `parentid`, `actiondef_objid`, `actiondef_name`, `pos`) VALUES ('RACT6d174068:14e3de9c20b:-7eeb', 'RUL6d174068:14e3de9c20b:-7fcb', 'RULADEF1b4af871:14e3cc46e09:-3543', 'calc-rpu-av', '0');

REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-128a4cad:146f96a678e:-7efa', 'calc-av', 'Calculate Assess Value', '20', 'calc-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-21ad68c1:146fc2282bb:-7b6e', 'calc-mv', 'Calculate Market Value', '5', 'calc-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-3151', 'calc-bldguse-mv', 'Calculate Actual Use Market Value', '24', 'calc-bldguse-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-4365', 'calc-bldguse-depreciation', 'Calculate Depreciation', '60', 'calc-bldguse-depreciation', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-4807', 'calc-depreciation-sked', 'Calculate Depreciation Rate', '55', 'calc-depreciation-sked', 'rpt', 'rptis.bldg.actions.CalcDepreciationFromSked');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-5573', 'add-derive-var', 'Add Derive Variable', '50', 'add-derive-var', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-619b', 'calc-predominant-av', 'Calculate Predominant Assess Value', '50', 'calc-predominant-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-723b', 'calc-adj', 'Calculate Adjustment', '35', 'calc-adj', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-79a8', 'calc-floor-mv', 'Calculate Floor Market Value', '15', 'calc-floor-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-7a02', 'calc-floor-bmv', 'Calculate Floor Base Market Value', '10', 'calc-floor-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-2486b0ca:146fff66c3e:-7ce5', 'adjust-uv', 'Adjust Unit Value', '2', 'adjust-uv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-39192c48:1471ebc2797:-7dae', 'calc-assess-level', 'Calculate Assess Level', '85', 'calc-assess-level', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-39192c48:1471ebc2797:-7dee', 'add-assessment-info', 'Add Assessment Info', '80', 'add-assessment-info', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-3e8edbea:156bc08656a:-6112', 'recalc-rpu-totalav', 'Recalculate RPU Total AV', '1100', 'recalc-rpu-totalav', 'rpt', 'rptis.actions.CalcTotalRPUAssessValue');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-585c89e6:16156f39eeb:-77aa', 'aggregate-bill-item', 'Aggregate Ledger Items', '12', 'aggregate-bill-item', 'landtax', 'rptis.landtax.actions.AggregateLedgerItem');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-585c89e6:16156f39eeb:-7dcb', 'remove-bill-item', 'Remove Ledger Item', '11', 'remove-bill-item', 'landtax', 'rptis.landtax.actions.RemoveLedgerItem');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-59249a93:1614f57bd58:-7db8', 'add-firecode', 'Add Fire Code', '10', 'add-firecode', 'landtax', 'rptis.landtax.actions.AddFireCode');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5e76cf73:14d69e9c549:-71e7', 'update-landdetail-adj', 'Update Appraisal Adjustment', '3', 'update-landdetail-adj', 'rpt', 'rptis.land.actions.UpdateLandDetailAdjustment');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5e76cf73:14d69e9c549:-7232', 'update-landdetail-actualuse-adj', 'Update Appraisal Actual Use Adjustment', '3', 'update-landdetail-actualuse-adj', 'rpt', 'rptis.land.actions.UpdateLandDetailActualUseAdjustment');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5e76cf73:14d69e9c549:-72c3', 'update-landdetail-value-adj', 'Update Appraisal Value Adjustment', '3', 'update-landdetail-value-adj', 'rpt', 'rptis.land.actions.UpdateLandDetailValueAdjustment');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5e76cf73:14d69e9c549:-7e09', 'update-adj', 'Update Adjustment', '2', 'update-adj', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5ed6c5b0:16145892be0:-6988', 'add-sef', 'Add SEF Entry', '5', 'add-sef', 'landtax', 'rptis.landtax.actions.AddSef');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-5ed6c5b0:16145892be0:-7d18', 'add-basic', 'Add Basic Entry', '1', 'add-basic', 'landtax', 'rptis.landtax.actions.AddBasic');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-60c99d04:1470b276e7f:-7c52', 'calc-bldguse-bmv', 'Calculate Actual Use Base Market Value', '20', 'calc-bldguse-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-66032c9:16155c11111:-7c6a', 'split-bill-item', 'Split Ledger Item', '10', 'split-bill-item', 'landtax', 'rptis.landtax.actions.SplitLedgerItem');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-78fba29f:161df51b937:-7089', 'add-share', 'Add Revenue Share', '28', 'add-share', 'landtax', 'rptis.landtax.actions.AddShare');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-78fba29f:161df51b937:-7568', 'add-billitem', 'Add Bill Item', '25', 'add-billitem', 'landtax', 'rptis.landtax.actions.AddBillItem');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-7c494b7d:161d65781c4:-7cb4', 'add-sh', 'Add Social Housing Entry', '8', 'add-sh', 'landtax', 'rptis.landtax.actions.AddSocialHousing');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF-7c494b7d:161d65781c4:-7d6a', 'add-basicidle', 'Add Idle Land Entry', '6', 'add-basicidle', 'landtax', 'rptis.landtax.actions.AddIdleLand');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1441128c:1471efa4c1c:-69a5', 'calc-assess-value', 'Calculate Assess Value', '90', 'calc-assess-value', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1b4af871:14e3cc46e09:-344d', 'add-derive-var', 'Add Derive Variable', '45', 'add-derive-var', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1b4af871:14e3cc46e09:-3543', 'calc-rpu-av', 'Calculate RPU Assessed Value', '13', 'calc-rpu-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1b4af871:14e3cc46e09:-358c', 'calc-rpu-al', 'Calculate RPU Assess Level', '12', 'calc-rpu-al', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1b4af871:14e3cc46e09:-35cc', 'calc-rpu-mv', 'Calculate RPU Market Value', '11', 'calc-rpu-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1b4af871:14e3cc46e09:-3612', 'calc-rpu-bmv', 'Calculate RPU Base Market Value', '10', 'calc-rpu-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1be07afa:1452a9809e9:-6958', 'create-tax-summary', 'Create Tax Summary', '20', 'create-tax-summary', 'landtax', 'rptis.landtax.actions.CreateTaxSummary');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1e772168:14c5a447e35:-6703', 'calc-mach-depreciation', 'Calculate Depreciation', '2', 'calc-mach-depreciation', 'rpt', 'rptis.mach.actions.CalcMachineDepreciation');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1e772168:14c5a447e35:-7e28', 'calc-mach-av', 'Calculate Machine Assessed Value', '6', 'calc-mach-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1e772168:14c5a447e35:-7eaf', 'calc-mach-mv', 'Calculate Machine Market Value', '2', 'calc-mach-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1e772168:14c5a447e35:-7ed1', 'calc-mach-bmv', 'Calculate Base Market Value', '1', 'calc-mach-bmv', 'rpt', 'rptis.mach.actions.CalcMachineBMV');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF1fcd83ed:149bc7d0f75:-7d4b', 'split-by-qtr', 'Split By Quarter', '0', 'split-by-qtr', 'LANDTAX', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF23f2d934:14719fd6b68:-725b', 'reset-adj', 'Reset Adjustment Value', '70', 'reset-adj', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF36885e11:150188b0d78:-7e0c', 'calc-depreciation-range', 'Calculate Depreciation Rate by Range', '56', 'calc-depreciation-range', 'rpt', 'rptis.bldg.actions.CalcDepreciationByRange');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF3afe51b9:146f7088d9c:-7c7b', 'calc-bmv', 'Calculate Base Market Value', '1', 'calc-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF3e2b89cb:146ff734573:-7c47', 'calc-bldg-age', 'Calculate Building Age', '1', 'calc-bldg-age', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF5022d8ba:1589ae965a4:-7b0e', 'add-planttree-assessment-info', 'Add Assessment', '100', 'add-planttree-assessment-info', 'rpt', 'rptis.planttree.actions.AddPlantTreeAssessmentInfo');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF57c48737:1472331021e:-7f84', 'calc-bldg-effectiveage', 'Calculate Building Effective Age', '2', 'calc-bldg-effectiveage', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF59614e16:14c5e56ecc8:-7ef4', 'calc-av', 'Calculate Assessed Value', '4', 'calc-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF59614e16:14c5e56ecc8:-7f1c', 'calc-mv', 'Calculate Market Value', '3', 'calc-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF59614e16:14c5e56ecc8:-7f42', 'calc-depreciation', 'Calculate Depreciation', '1', 'calc-depreciation', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF59614e16:14c5e56ecc8:-7f6b', 'calc-bmv', 'Calculate Base Market Value', '1', 'calc-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF5b4ac915:147baaa06b4:-7dbe', 'add-assessment-info', 'Add Assessment Summary', '50', 'add-assessment-info', 'rpt', 'rptis.land.actions.AddAssessmentInfo');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF5b84d618:1615428187f:-6904', 'calc-discount', 'Calculate Discount', '6', 'calc-discount', 'landtax', 'rptis.landtax.actions.CalcDiscount');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF5d750d7e:161889cc785:-7d47', 'set-bill-expiry', 'Set Bill Expiry Date', '20', 'set-bill-expiry', 'landtax', 'rptis.landtax.actions.SetBillExpiryDate');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF634d9a3c:161503ff1dc:-707a', 'calc-interest', 'Calculate Interest', '5', 'calc-interest', 'landtax', 'rptis.landtax.actions.CalcInterest');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF634d9a3c:161503ff1dc:-787a', 'calc-tax', 'Calculate Tax', '1001', 'calc-tax', 'landtax', 'rptis.landtax.actions.CalcTax');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF6b62feef:14c53ac1f59:-7e2c', 'calc-planttree-av', 'Calculate Assessed Value', '4', 'calc-planttree-av', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF6b62feef:14c53ac1f59:-7e59', 'calc-planttree-mv', 'Calculate Market Value', '3', 'calc-planttree-mv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF6b62feef:14c53ac1f59:-7e83', 'calc-planttree-adjustment', 'Calculate Adjustment', '2', 'calc-planttree-adjustment', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF6b62feef:14c53ac1f59:-7ea2', 'calc-planttree-bmv', 'Calculate Base Market Value', '1', 'calc-planttree-bmv', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF6d66cc31:1446cc9522e:-7d56', 'add-requirement', 'Add Requirement', '1', 'add-requirement', 'bpls', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF7efff901:15104440241:-7de4', 'recalc-rpuassessment', 'Recalculate Assessment AV', '1050', 'recalc-rpuassessment', 'rpt', 'rptis.actions.CalcRPUAssessValue');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF7efff901:15104440241:5e0b', 'add-assessment-info', 'Add Assessment Info', '1000', 'add-assessment-info', 'rpt', 'rptis.mach.actions.AddAssessmentInfo');
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF7efff901:15104fb0702:3868', 'calc-mach-al', 'Calculate Machine Assess Level', '5', 'calc-mach-al', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF7efff901:15104fb0702:4487', 'calc-machuse-al', 'Calculate Actual Use Assess Level', '10', 'calc-machuse-al', 'RPT', NULL);
REPLACE INTO `sys_rule_actiondef` (`objid`, `name`, `title`, `sortorder`, `actionname`, `domain`, `actionclass`) VALUES ('RULADEF7efff901:15104fb0702:4545', 'calc-machuse-av', 'Calculate Actual Use Assessed Value', '11', 'calc-machuse-av', 'RPT', NULL);

REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-128a4cad:146f96a678e:-7ee7', 'RULADEF-128a4cad:146f96a678e:-7efa', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-128a4cad:146f96a678e:-7ef0', 'RULADEF-128a4cad:146f96a678e:-7efa', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-21ad68c1:146fc2282bb:-7b30', 'RULADEF-21ad68c1:146fc2282bb:-7b6e', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-21ad68c1:146fc2282bb:-7b39', 'RULADEF-21ad68c1:146fc2282bb:-7b6e', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-30fe', 'RULADEF-2486b0ca:146fff66c3e:-3151', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-3105', 'RULADEF-2486b0ca:146fff66c3e:-3151', 'bldguse', '1', 'Building Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-4090', 'RULADEF-2486b0ca:146fff66c3e:-4365', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-4351', 'RULADEF-2486b0ca:146fff66c3e:-4365', 'bldguse', '1', 'Building Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-45b0', 'RULADEF-2486b0ca:146fff66c3e:-4807', 'bldgstructure', '1', 'Building Structure', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgStructure', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-5512', 'RULADEF-2486b0ca:146fff66c3e:-5573', 'aggregatetype', '3', 'Aggregation', NULL, 'lov', NULL, NULL, NULL, NULL, 'RPT_VAR_AGGRETATION_TYPES');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-552b', 'RULADEF-2486b0ca:146fff66c3e:-5573', 'expr', '4', 'Value Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-554a', 'RULADEF-2486b0ca:146fff66c3e:-5573', 'var', '2', 'Variable', NULL, 'lookup', 'rptparameter:lookup', 'objid', 'name', NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-6174', 'RULADEF-2486b0ca:146fff66c3e:-619b', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-618b', 'RULADEF-2486b0ca:146fff66c3e:-619b', 'rpu', '1', 'Building Real Property', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-7204', 'RULADEF-2486b0ca:146fff66c3e:-723b', 'expr', '3', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-7224', 'RULADEF-2486b0ca:146fff66c3e:-723b', 'adjustment', '1', 'Adjustment', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgAdjustment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-7994', 'RULADEF-2486b0ca:146fff66c3e:-79a8', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-799f', 'RULADEF-2486b0ca:146fff66c3e:-79a8', 'bldgfloor', '1', 'Building Floor', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgFloor', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-79dc', 'RULADEF-2486b0ca:146fff66c3e:-7a02', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-79e3', 'RULADEF-2486b0ca:146fff66c3e:-7a02', 'bldgfloor', '1', 'Building Floor', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgFloor', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-7cd2', 'RULADEF-2486b0ca:146fff66c3e:-7ce5', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-2486b0ca:146fff66c3e:-7cdb', 'RULADEF-2486b0ca:146fff66c3e:-7ce5', 'bldgstructure', '1', 'Building Structure', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgStructure', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-39192c48:1471ebc2797:-7da1', 'RULADEF-39192c48:1471ebc2797:-7dae', 'assessment', '1', 'Assessment', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.RPUAssessment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-39192c48:1471ebc2797:-7dd8', 'RULADEF-39192c48:1471ebc2797:-7dee', 'actualuseid', '2', 'Actual Use', NULL, 'var', NULL, NULL, NULL, 'string', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-39192c48:1471ebc2797:-7de1', 'RULADEF-39192c48:1471ebc2797:-7dee', 'bldguse', '1', 'Building Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-3e8edbea:156bc08656a:-60da', 'RULADEF-3e8edbea:156bc08656a:-6112', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-3e8edbea:156bc08656a:-60e2', 'RULADEF-3e8edbea:156bc08656a:-6112', 'rpu', '1', 'RPU', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.RPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-585c89e6:16156f39eeb:-7793', 'RULADEF-585c89e6:16156f39eeb:-77aa', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-585c89e6:16156f39eeb:-7d7e', 'RULADEF-585c89e6:16156f39eeb:-7dcb', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-59249a93:1614f57bd58:-7d94', 'RULADEF-59249a93:1614f57bd58:-7db8', 'av', '3', 'AV', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-59249a93:1614f57bd58:-7d9b', 'RULADEF-59249a93:1614f57bd58:-7db8', 'year', '2', 'Year', NULL, 'var', NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-59249a93:1614f57bd58:-7da4', 'RULADEF-59249a93:1614f57bd58:-7db8', 'avfact', '1', 'AV Info', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.AssessedValue', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-71d5', 'RULADEF-5e76cf73:14d69e9c549:-71e7', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-71dc', 'RULADEF-5e76cf73:14d69e9c549:-71e7', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-7222', 'RULADEF-5e76cf73:14d69e9c549:-7232', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-7229', 'RULADEF-5e76cf73:14d69e9c549:-7232', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-72ae', 'RULADEF-5e76cf73:14d69e9c549:-72c3', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-72b5', 'RULADEF-5e76cf73:14d69e9c549:-72c3', 'landdetail', '1', 'Land Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-7d9d', 'RULADEF-5e76cf73:14d69e9c549:-7e09', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5e76cf73:14d69e9c549:-7da4', 'RULADEF-5e76cf73:14d69e9c549:-7e09', 'adjustment', '1', 'Adjustment', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandAdjustment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-6966', 'RULADEF-5ed6c5b0:16145892be0:-6988', 'av', '3', 'AV', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-696d', 'RULADEF-5ed6c5b0:16145892be0:-6988', 'year', '2', 'Year', NULL, 'var', NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-6975', 'RULADEF-5ed6c5b0:16145892be0:-6988', 'avfact', '1', 'AV Info', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.AssessedValue', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-7cef', 'RULADEF-5ed6c5b0:16145892be0:-7d18', 'av', '3', 'AV', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-7cfd', 'RULADEF-5ed6c5b0:16145892be0:-7d18', 'year', '2', 'Year', NULL, 'var', NULL, NULL, NULL, 'integer', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-5ed6c5b0:16145892be0:-7d06', 'RULADEF-5ed6c5b0:16145892be0:-7d18', 'avfact', '1', 'AV Info', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.AssessedValue', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-60c99d04:1470b276e7f:-7c0e', 'RULADEF-60c99d04:1470b276e7f:-7c52', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-60c99d04:1470b276e7f:-7c15', 'RULADEF-60c99d04:1470b276e7f:-7c52', 'bldguse', '1', 'Building Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-66032c9:16155c11111:-7bac', 'RULADEF-66032c9:16155c11111:-7c6a', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-53f6', 'RULADEF-78fba29f:161df51b937:-7089', 'orgid', '3', 'Org', NULL, 'var', 'org:lookup', 'objid', 'name', 'String', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-7024', 'RULADEF-78fba29f:161df51b937:-7089', 'amtdue', '5', 'Amount Due', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-7031', 'RULADEF-78fba29f:161df51b937:-7089', 'payableparentacct', '4', 'Payable Account', NULL, 'lookup', 'cashreceiptitem:lookup', 'objid', 'title', NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-7046', 'RULADEF-78fba29f:161df51b937:-7089', 'orgclass', '2', 'Share Type', NULL, 'lov', NULL, NULL, NULL, NULL, 'RPT_BILLING_LGU_TYPES');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-706a', 'RULADEF-78fba29f:161df51b937:-7089', 'billitem', '1', 'Bill Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTBillItem', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-78fba29f:161df51b937:-7357', 'RULADEF-78fba29f:161df51b937:-7568', 'taxsummary', '1', 'Tax Summary', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerTaxSummaryFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7c2a', 'RULADEF-7c494b7d:161d65781c4:-7cb4', 'av', '3', 'AV', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7c31', 'RULADEF-7c494b7d:161d65781c4:-7cb4', 'year', '2', 'Year', NULL, 'var', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7c3a', 'RULADEF-7c494b7d:161d65781c4:-7cb4', 'avfact', '1', 'AV Info', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.AssessedValue', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7d48', 'RULADEF-7c494b7d:161d65781c4:-7d6a', 'av', '3', 'AV', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7d4f', 'RULADEF-7c494b7d:161d65781c4:-7d6a', 'year', '2', 'Year', NULL, 'var', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM-7c494b7d:161d65781c4:-7d57', 'RULADEF-7c494b7d:161d65781c4:-7d6a', 'avfact', '1', 'AV Info', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.AssessedValue', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM102ab3e1:147190e9fe4:-5a13', 'RULADEF-2486b0ca:146fff66c3e:-5573', 'bldguse', '1', 'Building Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM102ab3e1:147190e9fe4:-f75', 'RULADEF-2486b0ca:146fff66c3e:-723b', 'var', '2', 'Derived Variable', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgVariable', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1441128c:1471efa4c1c:-6969', 'RULADEF1441128c:1471efa4c1c:-69a5', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1441128c:1471efa4c1c:-698e', 'RULADEF1441128c:1471efa4c1c:-69a5', 'assessment', '1', 'Assessment Info', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.RPUAssessment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-33b8', 'RULADEF1b4af871:14e3cc46e09:-344d', 'expr', '4', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-341d', 'RULADEF1b4af871:14e3cc46e09:-344d', 'aggregatetype', '3', 'Aggregation', NULL, 'lov', NULL, NULL, NULL, NULL, 'RPT_VAR_AGGRETATION_TYPES');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-342a', 'RULADEF1b4af871:14e3cc46e09:-344d', 'var', '2', 'Variable', NULL, 'lookup', 'rptparameter:lookup', 'objid', 'name', NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-343a', 'RULADEF1b4af871:14e3cc46e09:-344d', 'refid', '1', 'Reference ID', NULL, 'var', NULL, NULL, NULL, 'String', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-3531', 'RULADEF1b4af871:14e3cc46e09:-3543', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-3538', 'RULADEF1b4af871:14e3cc46e09:-3543', 'miscrpu', '1', 'Miscellaneous RPU', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-357a', 'RULADEF1b4af871:14e3cc46e09:-358c', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-3581', 'RULADEF1b4af871:14e3cc46e09:-358c', 'miscrpu', '1', 'Miscellaneous RPU', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-35ba', 'RULADEF1b4af871:14e3cc46e09:-35cc', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-35c1', 'RULADEF1b4af871:14e3cc46e09:-35cc', 'miscrpu', '1', 'Miscellaneous RPU', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-35fc', 'RULADEF1b4af871:14e3cc46e09:-3612', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1b4af871:14e3cc46e09:-3603', 'RULADEF1b4af871:14e3cc46e09:-3612', 'miscrpu', '1', 'Miscellaneous RPU', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1be07afa:1452a9809e9:-6948', 'RULADEF1be07afa:1452a9809e9:-6958', 'var', '3', 'Variable Name', NULL, 'lookup', 'rptparameter:lookup', 'name', 'name', NULL, '');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1be07afa:1452a9809e9:-694f', 'RULADEF1be07afa:1452a9809e9:-6958', 'rptledgeritem', '1', 'RPT Ledger Item', '', 'var', '', '', '', 'rptis.landtax.facts.RPTLedgerItemFact', '');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-66ee', 'RULADEF1e772168:14c5a447e35:-6703', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-66f5', 'RULADEF1e772168:14c5a447e35:-6703', 'machine', '1', 'Machinery', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7e16', 'RULADEF1e772168:14c5a447e35:-7e28', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7e1d', 'RULADEF1e772168:14c5a447e35:-7e28', 'machine', '1', 'Machinery', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7e9d', 'RULADEF1e772168:14c5a447e35:-7eaf', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7ea4', 'RULADEF1e772168:14c5a447e35:-7eaf', 'machine', '1', 'Machinery', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7ebf', 'RULADEF1e772168:14c5a447e35:-7ed1', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1e772168:14c5a447e35:-7ec6', 'RULADEF1e772168:14c5a447e35:-7ed1', 'machine', '1', 'Machinery', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1ef00448:161e1e4995a:-5473', 'RULADEF-78fba29f:161df51b937:-7089', 'rate', '6', 'Share (decimal)', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM1fcd83ed:149bc7d0f75:-7d25', 'RULADEF1fcd83ed:149bc7d0f75:-7d4b', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM23f2d934:14719fd6b68:-7241', 'RULADEF23f2d934:14719fd6b68:-725b', 'adjustment', '1', 'Building Adjustment', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgAdjustment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM36885e11:150188b0d78:-7dfa', 'RULADEF36885e11:150188b0d78:-7e0c', 'bldgstructure', '1', 'Building Structure', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgStructure', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM3afe51b9:146f7088d9c:-6459', 'RULADEF3afe51b9:146f7088d9c:-7c7b', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM3afe51b9:146f7088d9c:-6b8d', 'RULADEF3afe51b9:146f7088d9c:-7c7b', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM3e2b89cb:146ff734573:-7c34', 'RULADEF3e2b89cb:146ff734573:-7c47', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM3e2b89cb:146ff734573:-7c3c', 'RULADEF3e2b89cb:146ff734573:-7c47', 'rpu', '1', 'Building Real Property', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM49a3c540:14e51feb8f6:-4c86', 'RULADEF-2486b0ca:146fff66c3e:-723b', 'var', '2', 'Variable', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.RPTVariable', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5022d8ba:1589ae965a4:-7aee', 'RULADEF5022d8ba:1589ae965a4:-7b0e', 'planttreedetail', '1', 'Plant/Tree', NULL, 'var', NULL, NULL, NULL, 'rptis.planttree.facts.PlantTreeDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM57c48737:1472331021e:-7f56', 'RULADEF57c48737:1472331021e:-7f84', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM57c48737:1472331021e:-7f5d', 'RULADEF57c48737:1472331021e:-7f84', 'rpu', '1', 'Building Real Property', NULL, 'var', NULL, NULL, NULL, 'rptis.bldg.facts.BldgRPU', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7ee2', 'RULADEF59614e16:14c5e56ecc8:-7ef4', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7ee9', 'RULADEF59614e16:14c5e56ecc8:-7ef4', 'miscitem', '1', 'Miscellaneous Item', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscItem', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f0a', 'RULADEF59614e16:14c5e56ecc8:-7f1c', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f11', 'RULADEF59614e16:14c5e56ecc8:-7f1c', 'miscitem', '1', 'Miscelleneous Item', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscItem', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f30', 'RULADEF59614e16:14c5e56ecc8:-7f42', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f37', 'RULADEF59614e16:14c5e56ecc8:-7f42', 'miscitem', '1', 'Miscellaneous Item', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscItem', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f55', 'RULADEF59614e16:14c5e56ecc8:-7f6b', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM59614e16:14c5e56ecc8:-7f5e', 'RULADEF59614e16:14c5e56ecc8:-7f6b', 'miscitem', '1', 'Miscellaneous Item', NULL, 'var', NULL, NULL, NULL, 'rptis.misc.facts.MiscItem', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5b4ac915:147baaa06b4:-6cb3', 'RULADEF5b4ac915:147baaa06b4:-7dbe', 'classification', '2', 'Classification', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.Classification', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5b4ac915:147baaa06b4:-7d98', 'RULADEF5b4ac915:147baaa06b4:-7dbe', 'landdetail', '1', 'Land Item Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.land.facts.LandDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5b84d618:1615428187f:-68cf', 'RULADEF5b84d618:1615428187f:-6904', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5b84d618:1615428187f:-68e9', 'RULADEF5b84d618:1615428187f:-6904', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5d750d7e:161889cc785:-7bcf', 'RULADEF5d750d7e:161889cc785:-7d47', 'expr', '2', 'Expiry Date', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM5d750d7e:161889cc785:-7bef', 'RULADEF5d750d7e:161889cc785:-7d47', 'bill', '1', 'Bill', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.Bill', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM634d9a3c:161503ff1dc:-6f9f', 'RULADEF634d9a3c:161503ff1dc:-707a', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM634d9a3c:161503ff1dc:-6fb7', 'RULADEF634d9a3c:161503ff1dc:-707a', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM634d9a3c:161503ff1dc:-7848', 'RULADEF634d9a3c:161503ff1dc:-787a', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM634d9a3c:161503ff1dc:-7860', 'RULADEF634d9a3c:161503ff1dc:-787a', 'rptledgeritem', '1', 'Ledger Item', NULL, 'var', NULL, NULL, NULL, 'rptis.landtax.facts.RPTLedgerItemFact', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM649122d9:1463c83c30a:-7f1e', 'RULADEF1be07afa:1452a9809e9:-6958', 'revperiod', '2', 'Revenue Period', NULL, 'lov', NULL, NULL, NULL, NULL, 'RPT_REVENUE_PERIODS');
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e1c', 'RULADEF6b62feef:14c53ac1f59:-7e2c', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e23', 'RULADEF6b62feef:14c53ac1f59:-7e2c', 'planttreedetail', '1', 'Plant/Tree Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.planttree.facts.PlantTreeDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e48', 'RULADEF6b62feef:14c53ac1f59:-7e59', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e4f', 'RULADEF6b62feef:14c53ac1f59:-7e59', 'planttreedetail', '1', 'Plant/Tree Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.planttree.facts.PlantTreeDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e6d', 'RULADEF6b62feef:14c53ac1f59:-7e83', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e74', 'RULADEF6b62feef:14c53ac1f59:-7e83', 'planttreedetail', '1', 'Plant/Tree Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.planttree.facts.PlantTreeDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e90', 'RULADEF6b62feef:14c53ac1f59:-7ea2', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6b62feef:14c53ac1f59:-7e97', 'RULADEF6b62feef:14c53ac1f59:-7ea2', 'planttreedetail', '1', 'Plant/Tree Appraisal', NULL, 'var', NULL, NULL, NULL, 'rptis.planttree.facts.PlantTreeDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM6d66cc31:1446cc9522e:-7d3c', 'RULADEF6d66cc31:1446cc9522e:-7d56', 'requirementtype', '1', 'Requirement Type', NULL, 'lookup', 'rptrequirementtype:lookup', 'objid', 'name', NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104440241:-7d8e', 'RULADEF7efff901:15104440241:-7de4', 'expr', '2', 'Computation', NULL, 'expression', NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104440241:-7d95', 'RULADEF7efff901:15104440241:-7de4', 'rpuassessment', '1', 'Assessment', NULL, 'var', NULL, NULL, NULL, 'rptis.facts.RPUAssessment', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104440241:5e76', 'RULADEF7efff901:15104440241:5e0b', 'machuse', '1', 'Machine Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineActualUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104fb0702:3875', 'RULADEF7efff901:15104fb0702:3868', 'machuse', '1', 'Machine Use', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineActualUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104fb0702:3886', 'RULADEF7efff901:15104fb0702:3868', 'machine', '2', 'Machine', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineDetail', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104fb0702:449a', 'RULADEF7efff901:15104fb0702:4487', 'machuse', '1', 'Machine Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineActualUse', NULL);
REPLACE INTO `sys_rule_actiondef_param` (`objid`, `parentid`, `name`, `sortorder`, `title`, `datatype`, `handler`, `lookuphandler`, `lookupkey`, `lookupvalue`, `vardatatype`, `lovname`) VALUES ('ACTPARAM7efff901:15104fb0702:4552', 'RULADEF7efff901:15104fb0702:4545', 'machuse', '1', 'Machine Actual Use', NULL, 'var', NULL, NULL, NULL, 'rptis.mach.facts.MachineActualUse', NULL);

REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-15f7fe9f:15cf6ec9fa5:-7fbd', 'RA-15f7fe9f:15cf6ec9fa5:-7fbf', 'ACTPARAM-128a4cad:146f96a678e:-7ef0', NULL, NULL, 'RC-15f7fe9f:15cf6ec9fa5:-7fc3', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-15f7fe9f:15cf6ec9fa5:-7fbe', 'RA-15f7fe9f:15cf6ec9fa5:-7fbf', 'ACTPARAM-128a4cad:146f96a678e:-7ee7', NULL, NULL, NULL, NULL, '@ROUNDTOTEN( MV * AL / 100.0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f04', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f0f', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f05', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f06', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2da6', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f07', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_SEF_PREVIOUS_PROVINCE_SHARE', 'RPT SEF PREVIOUS PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f08', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f09', 'RA-293918d4:16209768e19:-7f0a', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.50', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f10', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f19', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f11', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f12', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2c08', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f13', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_SEFINT_PREVIOUS_PROVINCE_SHARE', 'RPT SEF PENALTY PREVIOUS PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f14', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f15', 'RA-293918d4:16209768e19:-7f16', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.50', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f1f', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f28', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f20', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f21', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2a60', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f22', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_SEF_CURRENT_PROVINCE_SHARE', 'RPT SEF CURRENT PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f23', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f24', 'RA-293918d4:16209768e19:-7f25', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.50', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f2b', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f36', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f2c', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f2d', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-28b8', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f2e', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_SEFINT_CURRENT_PROVINCE_SHARE', 'RPT SEF PENALTY CURRENT PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f2f', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f30', 'RA-293918d4:16209768e19:-7f31', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.50', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f40', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f4b', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f41', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f42', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2710', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f43', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_SEF_ADVANCE_PROVINCE_SHARE', 'RPT SEF ADVANCE PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f44', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f45', 'RA-293918d4:16209768e19:-7f46', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.50', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f4f', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.35', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f50', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f51', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_ADVANCE_PROVINCE_SHARE', 'RPT BASIC ADVANCE PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f52', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2568', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f53', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f54', 'RA-293918d4:16209768e19:-7f55', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f58', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f5b', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.35', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f5c', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f5d', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASICINT_CURRENT_PROVINCE_SHARE', 'RPT BASIC PENALTY CURRENT PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f5e', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-23c0', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f5f', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f60', 'RA-293918d4:16209768e19:-7f61', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f64', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f67', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.35', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f68', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f69', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_CURRENT_PROVINCE_SHARE', 'RPT BASIC CURRENT PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f6a', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-2218', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f6b', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f6c', 'RA-293918d4:16209768e19:-7f6d', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f72', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f73', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.35', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f74', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f75', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASICINT_PREVIOUS_PROVINCE_SHARE', 'RPT BASIC PENALTY PREVIOUS PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f76', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-206e', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f77', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f78', 'RA-293918d4:16209768e19:-7f79', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f7e', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f82', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.35', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f83', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f84', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_PREVIOUS_PROVINCE_SHARE', 'RPT BASIC PREVIOUS PROVINCE SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f85', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCONST713e35a1:1620963487c:-1ec6', 'PROVID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f86', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'province', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-293918d4:16209768e19:-7f87', 'RA-293918d4:16209768e19:-7f88', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC-293918d4:16209768e19:-7f8b', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-69b5f604:15cfc6b3e74:-7e34', 'RA-69b5f604:15cfc6b3e74:-7e36', 'ACTPARAM1441128c:1471efa4c1c:-698e', NULL, NULL, 'RC-69b5f604:15cfc6b3e74:-7e3b', 'BA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-69b5f604:15cfc6b3e74:-7e35', 'RA-69b5f604:15cfc6b3e74:-7e36', 'ACTPARAM1441128c:1471efa4c1c:-6969', NULL, NULL, NULL, NULL, '@ROUND( MV * AL  / 100.0 , 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-6bcddeab:16188c09983:-7eda', 'RA-6bcddeab:16188c09983:-7edc', 'ACTPARAM5d750d7e:161889cc785:-7bef', NULL, NULL, 'RC-6bcddeab:16188c09983:-7ee5', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-6bcddeab:16188c09983:-7edb', 'RA-6bcddeab:16188c09983:-7edc', 'ACTPARAM5d750d7e:161889cc785:-7bcf', NULL, NULL, NULL, NULL, '@MONTHEND(@DATE(CY, 12, 1)); ', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-6bcddeab:16188c09983:-7fd3', 'RA-6bcddeab:16188c09983:-7fd5', 'ACTPARAM5d750d7e:161889cc785:-7bef', NULL, NULL, 'RC-6bcddeab:16188c09983:-7fd7', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP-6bcddeab:16188c09983:-7fd4', 'RA-6bcddeab:16188c09983:-7fd5', 'ACTPARAM5d750d7e:161889cc785:-7bcf', NULL, NULL, NULL, NULL, '@MONTHEND( CDATE  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP13423d65:162270a87db:-7c64', 'RA13423d65:162270a87db:-7c66', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RC13423d65:162270a87db:-7c6d', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP13423d65:162270a87db:-7c65', 'RA13423d65:162270a87db:-7c66', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, 'TAX * 0.10', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP13423d65:162270a87db:-7ccc', 'RA13423d65:162270a87db:-7cce', 'ACTPARAM634d9a3c:161503ff1dc:-6fb7', NULL, NULL, 'RC13423d65:162270a87db:-7cd6', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP13423d65:162270a87db:-7ccd', 'RA13423d65:162270a87db:-7cce', 'ACTPARAM634d9a3c:161503ff1dc:-6f9f', NULL, NULL, NULL, NULL, '@IIF( NMON * 0.02 > 0.72 , TAX * 0.72 , TAX * NMON * 0.02  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP13524a8b:161b645b0bf:-7fdc', 'RA13524a8b:161b645b0bf:-7fdd', 'ACTPARAM-66032c9:16155c11111:-7bac', NULL, NULL, 'RC13524a8b:161b645b0bf:-7fe0', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP16a7ee38:15cfcd300fe:-7fb3', 'RA16a7ee38:15cfcd300fe:-7fb7', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCC16a7ee38:15cfcd300fe:-7fbb', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP16a7ee38:15cfcd300fe:-7fb4', 'RA16a7ee38:15cfcd300fe:-7fb7', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RP-28dc975:156bcab666c:-6a4d', 'TOTALAV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP16a7ee38:15cfcd300fe:-7fb5', 'RA16a7ee38:15cfcd300fe:-7fb7', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP16a7ee38:15cfcd300fe:-7fb6', 'RA16a7ee38:15cfcd300fe:-7fb7', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP67caf065:1724e308e34:-732f', 'RA67caf065:1724e308e34:-7331', 'ACTPARAM634d9a3c:161503ff1dc:-6f9f', NULL, NULL, NULL, NULL, 'TAX * NMON * 0.02', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP67caf065:1724e308e34:-7330', 'RA67caf065:1724e308e34:-7331', 'ACTPARAM634d9a3c:161503ff1dc:-6fb7', NULL, NULL, 'RC67caf065:1724e308e34:-7336', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP67caf065:1724e308e34:-7380', 'RA67caf065:1724e308e34:-7382', 'ACTPARAM634d9a3c:161503ff1dc:-6fb7', NULL, NULL, 'RC67caf065:1724e308e34:-738e', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RAP67caf065:1724e308e34:-7381', 'RA67caf065:1724e308e34:-7382', 'ACTPARAM634d9a3c:161503ff1dc:-6f9f', NULL, NULL, NULL, NULL, 'TAX * NMON * 0.02', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-103fed47:146ffb40356:-7c4f', 'RACT-103fed47:146ffb40356:-7c51', 'ACTPARAM3e2b89cb:146ff734573:-7c34', NULL, NULL, NULL, NULL, 'YRAPPRAISED - YRCOMPLETED', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-103fed47:146ffb40356:-7c50', 'RACT-103fed47:146ffb40356:-7c51', 'ACTPARAM3e2b89cb:146ff734573:-7c3c', NULL, NULL, 'RCOND-103fed47:146ffb40356:-7d40', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-13574fd2:1621b509f0b:-7133', 'RACT-13574fd2:1621b509f0b:-7134', 'ACTPARAM36885e11:150188b0d78:-7dfa', NULL, NULL, 'RCOND-2486b0ca:146fff66c3e:-445d', 'BS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-2adc', 'RACT-2486b0ca:146fff66c3e:-2ade', 'ACTPARAM-2486b0ca:146fff66c3e:-30fe', NULL, NULL, NULL, NULL, '@ROUND( BMV + ADJ - DEP  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-2add', 'RACT-2486b0ca:146fff66c3e:-2ade', 'ACTPARAM-2486b0ca:146fff66c3e:-3105', NULL, NULL, 'RCOND-2486b0ca:146fff66c3e:-2bf1', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-37a0', 'RACT-2486b0ca:146fff66c3e:-37a2', 'ACTPARAM-2486b0ca:146fff66c3e:-7994', NULL, NULL, NULL, NULL, '@ROUND( BMV + ADJ )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-37a1', 'RACT-2486b0ca:146fff66c3e:-37a2', 'ACTPARAM-2486b0ca:146fff66c3e:-799f', NULL, NULL, 'RCOND-2486b0ca:146fff66c3e:-3888', 'BF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-3d30', 'RACT-2486b0ca:146fff66c3e:-3d32', 'ACTPARAM-2486b0ca:146fff66c3e:-4090', NULL, NULL, NULL, NULL, '@ROUND( (BMV + ADJUSTMENT ) * DPRATE   / 100.0  , 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-3d31', 'RACT-2486b0ca:146fff66c3e:-3d32', 'ACTPARAM-2486b0ca:146fff66c3e:-4351', NULL, NULL, 'RCOND-2486b0ca:146fff66c3e:-3ed1', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-6a10', 'RACT-2486b0ca:146fff66c3e:-6a12', 'ACTPARAM-2486b0ca:146fff66c3e:-79dc', NULL, NULL, NULL, NULL, 'AREA * UV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-2486b0ca:146fff66c3e:-6a11', 'RACT-2486b0ca:146fff66c3e:-6a12', 'ACTPARAM-2486b0ca:146fff66c3e:-79e3', NULL, NULL, 'RCOND-2486b0ca:146fff66c3e:-6aad', 'BF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-28dc975:156bcab666c:-5e3a', 'RACT-28dc975:156bcab666c:-5e3c', 'ACTPARAM-3e8edbea:156bc08656a:-60da', NULL, NULL, NULL, NULL, '@ROUNDTOTEN( AV  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-28dc975:156bcab666c:-5e3b', 'RACT-28dc975:156bcab666c:-5e3c', 'ACTPARAM-3e8edbea:156bc08656a:-60e2', NULL, NULL, 'RCOND-28dc975:156bcab666c:-6051', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-32ce', 'RACT-46fca07e:14c545f3e6a:-32d0', 'ACTPARAM-2486b0ca:146fff66c3e:-79dc', NULL, NULL, NULL, NULL, '@ROUND( BMV, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-32cf', 'RACT-46fca07e:14c545f3e6a:-32d0', 'ACTPARAM-2486b0ca:146fff66c3e:-79e3', NULL, NULL, 'RCOND-46fca07e:14c545f3e6a:-3353', 'BF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-3420', 'RACT-46fca07e:14c545f3e6a:-3422', 'ACTPARAM-60c99d04:1470b276e7f:-7c0e', NULL, NULL, NULL, NULL, '@ROUND(BMV, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-3421', 'RACT-46fca07e:14c545f3e6a:-3422', 'ACTPARAM-60c99d04:1470b276e7f:-7c15', NULL, NULL, 'RCOND-46fca07e:14c545f3e6a:-34b0', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-763b', 'RACT-46fca07e:14c545f3e6a:-763d', 'ACTPARAM-21ad68c1:146fc2282bb:-7b30', NULL, NULL, NULL, NULL, '@ROUND( BMV + ADJ, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-763c', 'RACT-46fca07e:14c545f3e6a:-763d', 'ACTPARAM-21ad68c1:146fc2282bb:-7b39', NULL, NULL, 'RCOND-46fca07e:14c545f3e6a:-7707', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-77b8', 'RACT-46fca07e:14c545f3e6a:-77ba', 'ACTPARAM3afe51b9:146f7088d9c:-6b8d', NULL, NULL, NULL, NULL, '@ROUND( AREA * UV, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-46fca07e:14c545f3e6a:-77b9', 'RACT-46fca07e:14c545f3e6a:-77ba', 'ACTPARAM3afe51b9:146f7088d9c:-6459', NULL, NULL, 'RCOND-46fca07e:14c545f3e6a:-786f', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-585c89e6:16156f39eeb:-7426', 'RACT-585c89e6:16156f39eeb:-7427', 'ACTPARAM-585c89e6:16156f39eeb:-7793', NULL, NULL, 'RCOND-585c89e6:16156f39eeb:-7586', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6e11', 'RACT-5e76cf73:14d69e9c549:-6e13', 'ACTPARAM-5e76cf73:14d69e9c549:-72ae', NULL, NULL, NULL, NULL, '@ROUND( LVADJ, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6e12', 'RACT-5e76cf73:14d69e9c549:-6e13', 'ACTPARAM-5e76cf73:14d69e9c549:-72b5', NULL, NULL, 'RCOND-5e76cf73:14d69e9c549:-701c', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6e71', 'RACT-5e76cf73:14d69e9c549:-6e73', 'ACTPARAM-5e76cf73:14d69e9c549:-7222', NULL, NULL, NULL, NULL, '@ROUND( AUADJ, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6e72', 'RACT-5e76cf73:14d69e9c549:-6e73', 'ACTPARAM-5e76cf73:14d69e9c549:-7229', NULL, NULL, 'RCOND-5e76cf73:14d69e9c549:-701c', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6ecc', 'RACT-5e76cf73:14d69e9c549:-6ece', 'ACTPARAM-5e76cf73:14d69e9c549:-71d5', NULL, NULL, NULL, NULL, '@ROUND( ADJ, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-6ecd', 'RACT-5e76cf73:14d69e9c549:-6ece', 'ACTPARAM-5e76cf73:14d69e9c549:-71dc', NULL, NULL, 'RCOND-5e76cf73:14d69e9c549:-701c', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-7d12', 'RACT-5e76cf73:14d69e9c549:-7d14', 'ACTPARAM-5e76cf73:14d69e9c549:-7d9d', NULL, NULL, NULL, NULL, '@ROUND( ADJAMOUNT, 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-5e76cf73:14d69e9c549:-7d13', 'RACT-5e76cf73:14d69e9c549:-7d14', 'ACTPARAM-5e76cf73:14d69e9c549:-7da4', NULL, NULL, 'RCOND-5e76cf73:14d69e9c549:-7e5d', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-60c99d04:1470b276e7f:-7a50', 'RACT-60c99d04:1470b276e7f:-7a52', 'ACTPARAM-60c99d04:1470b276e7f:-7c0e', NULL, NULL, NULL, NULL, '@ROUND( BUAREA * BASEVALUE  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-60c99d04:1470b276e7f:-7a51', 'RACT-60c99d04:1470b276e7f:-7a52', 'ACTPARAM-60c99d04:1470b276e7f:-7c15', NULL, NULL, 'RCOND-60c99d04:1470b276e7f:-7dd3', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-6c4ec747:154bd626092:-4448', 'RACT-6c4ec747:154bd626092:-444a', 'ACTPARAM1e772168:14c5a447e35:-7e9d', NULL, NULL, NULL, NULL, '@ROUND(SWORNAMT, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-6c4ec747:154bd626092:-4449', 'RACT-6c4ec747:154bd626092:-444a', 'ACTPARAM1e772168:14c5a447e35:-7ea4', NULL, NULL, 'RCOND-6c4ec747:154bd626092:-55c3', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-6c4ec747:154bd626092:-54b7', 'RACT-6c4ec747:154bd626092:-54b9', 'ACTPARAM1e772168:14c5a447e35:-7ebf', NULL, NULL, NULL, NULL, '@ROUND(SWORNAMT, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-6c4ec747:154bd626092:-54b8', 'RACT-6c4ec747:154bd626092:-54b9', 'ACTPARAM1e772168:14c5a447e35:-7ec6', NULL, NULL, 'RCOND-6c4ec747:154bd626092:-55c3', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-58a4', 'RACT-762e9176:15d067a9c42:-58a6', 'ACTPARAM-3e8edbea:156bc08656a:-60da', NULL, NULL, NULL, NULL, '@ROUNDTOTEN( TOTALAV)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-58a5', 'RACT-762e9176:15d067a9c42:-58a6', 'ACTPARAM-3e8edbea:156bc08656a:-60e2', NULL, NULL, 'RCOND-762e9176:15d067a9c42:-5928', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-5b1e', 'RACT-762e9176:15d067a9c42:-5b22', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-5b1f', 'RACT-762e9176:15d067a9c42:-5b22', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-5b20', 'RACT-762e9176:15d067a9c42:-5b22', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P-79a9a347:15cfcae84de:-5edb', 'TOTAL_AV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-762e9176:15d067a9c42:-5b21', 'RACT-762e9176:15d067a9c42:-5b22', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST-762e9176:15d067a9c42:-5d1b', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-78fba29f:161df51b937:-70ec', 'RACT-78fba29f:161df51b937:-70ed', 'ACTPARAM-78fba29f:161df51b937:-7357', NULL, NULL, 'RCOND-78fba29f:161df51b937:-7478', 'RLTS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1c98', 'RACT-79a9a347:15cfcae84de:-1c9a', 'ACTPARAM-3e8edbea:156bc08656a:-60da', NULL, NULL, NULL, NULL, '@ROUNDTOTEN(TOTALAV)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1c99', 'RACT-79a9a347:15cfcae84de:-1c9a', 'ACTPARAM-3e8edbea:156bc08656a:-60e2', NULL, NULL, 'RCOND-79a9a347:15cfcae84de:-1e8b', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1f41', 'RACT-79a9a347:15cfcae84de:-1f45', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1f42', 'RACT-79a9a347:15cfcae84de:-1f45', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1f43', 'RACT-79a9a347:15cfcae84de:-1f45', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P-79a9a347:15cfcae84de:-5edb', 'TOTAL_AV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-1f44', 'RACT-79a9a347:15cfcae84de:-1f45', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST-79a9a347:15cfcae84de:-c0a', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-525', 'RACT-79a9a347:15cfcae84de:-527', 'ACTPARAM1e772168:14c5a447e35:-7e16', NULL, NULL, NULL, NULL, '@ROUND(MV * AL  / 100.0, 2);', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-526', 'RACT-79a9a347:15cfcae84de:-527', 'ACTPARAM1e772168:14c5a447e35:-7e1d', NULL, NULL, 'RCOND-79a9a347:15cfcae84de:-928', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-5e18', 'RACT-79a9a347:15cfcae84de:-5e1c', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-5e19', 'RACT-79a9a347:15cfcae84de:-5e1c', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-5e1a', 'RACT-79a9a347:15cfcae84de:-5e1c', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P-79a9a347:15cfcae84de:-5edb', 'TOTAL_AV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-5e1b', 'RACT-79a9a347:15cfcae84de:-5e1c', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST-79a9a347:15cfcae84de:-61bf', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-6d84', 'RACT-79a9a347:15cfcae84de:-6d86', 'ACTPARAM-3e8edbea:156bc08656a:-60da', NULL, NULL, NULL, NULL, '@ROUNDTOTEN(AV );', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:-6d85', 'RACT-79a9a347:15cfcae84de:-6d86', 'ACTPARAM-3e8edbea:156bc08656a:-60e2', NULL, NULL, 'RCOND-79a9a347:15cfcae84de:-6ebc', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:1101', 'RACT-79a9a347:15cfcae84de:1100', 'ACTPARAM6b62feef:14c53ac1f59:-7e23', NULL, NULL, 'RCOND-79a9a347:15cfcae84de:fb4', 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:1102', 'RACT-79a9a347:15cfcae84de:1100', 'ACTPARAM6b62feef:14c53ac1f59:-7e1c', NULL, NULL, NULL, NULL, '@ROUND(MV * AL / 100.0);', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:514f', 'RACT-79a9a347:15cfcae84de:514e', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST-79a9a347:15cfcae84de:50f0', 'RPUID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:5150', 'RACT-79a9a347:15cfcae84de:514e', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P-79a9a347:15cfcae84de:-5edb', 'TOTAL_AV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:5151', 'RACT-79a9a347:15cfcae84de:514e', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:5152', 'RACT-79a9a347:15cfcae84de:514e', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:56d8', 'RACT-79a9a347:15cfcae84de:56d7', 'ACTPARAM-3e8edbea:156bc08656a:-60e2', NULL, NULL, 'RCOND-79a9a347:15cfcae84de:553c', 'RPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-79a9a347:15cfcae84de:56d9', 'RACT-79a9a347:15cfcae84de:56d7', 'ACTPARAM-3e8edbea:156bc08656a:-60da', NULL, NULL, NULL, NULL, '@ROUNDTOTEN(TOTALAV)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-6f2c', 'RACT-7deff7e5:161b60a3048:-6f2e', 'ACTPARAM-7deff7e5:161b60a3048:-71f6', NULL, NULL, NULL, NULL, 'if (LAST_YR_PAID + 1 == CY && LAST_QTR_PAID == 4 && CQTR == 1 )\n	return @MONTHEND(@DATE(CY, CQTR*3, 1));\n\nif (LAST_YR_PAID == CY && LAST_QTR_PAID + 1 == CQTR )\n	return @MONTHEND( @DATE(CY, CQTR*3, 1));\n\nreturn @MONTHEND( CURRDATE);\n', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-6f2d', 'RACT-7deff7e5:161b60a3048:-6f2e', 'ACTPARAM-7deff7e5:161b60a3048:-71fe', NULL, NULL, 'RCOND5d750d7e:161889cc785:-6f08', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-6fe1', 'RACT-7deff7e5:161b60a3048:-6fe3', 'ACTPARAM-7deff7e5:161b60a3048:-71f6', NULL, NULL, NULL, NULL, '@MONTHEND( CDATE )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-6fe2', 'RACT-7deff7e5:161b60a3048:-6fe3', 'ACTPARAM-7deff7e5:161b60a3048:-71fe', NULL, NULL, 'RC-6bcddeab:16188c09983:-7fd7', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-708c', 'RACT-7deff7e5:161b60a3048:-708e', 'ACTPARAM-7deff7e5:161b60a3048:-71f6', NULL, NULL, NULL, NULL, '@MONTHEND(@DATE(CY, 12, 1));', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-708d', 'RACT-7deff7e5:161b60a3048:-708e', 'ACTPARAM-7deff7e5:161b60a3048:-71fe', NULL, NULL, 'RC-6bcddeab:16188c09983:-7f0b', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-7167', 'RACT-7deff7e5:161b60a3048:-7169', 'ACTPARAM-7deff7e5:161b60a3048:-71f6', NULL, NULL, NULL, NULL, '@MONTHEND(@DATE(CY, 12, 1));', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-7deff7e5:161b60a3048:-7168', 'RACT-7deff7e5:161b60a3048:-7169', 'ACTPARAM-7deff7e5:161b60a3048:-71fe', NULL, NULL, 'RC-6bcddeab:16188c09983:-7ee5', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-a35dd35:14e51ec3311:-5c19', 'RACT-a35dd35:14e51ec3311:-5c1b', 'ACTPARAM1b4af871:14e3cc46e09:-35ba', NULL, NULL, NULL, NULL, 'SWORNAMT * (100 - DPRATE ) / 100.0', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-a35dd35:14e51ec3311:-5c1a', 'RACT-a35dd35:14e51ec3311:-5c1b', 'ACTPARAM1b4af871:14e3cc46e09:-35c1', NULL, NULL, 'RCOND-a35dd35:14e51ec3311:-5d14', 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-a35dd35:14e51ec3311:-5c75', 'RACT-a35dd35:14e51ec3311:-5c77', 'ACTPARAM1b4af871:14e3cc46e09:-35fc', NULL, NULL, NULL, NULL, 'SWORNAMT * (100 - DPRATE ) / 100.0', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT-a35dd35:14e51ec3311:-5c76', 'RACT-a35dd35:14e51ec3311:-5c77', 'ACTPARAM1b4af871:14e3cc46e09:-3603', NULL, NULL, 'RCOND-a35dd35:14e51ec3311:-5d14', 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1441128c:1471efa4c1c:-6b96', 'RACT1441128c:1471efa4c1c:-6b97', 'ACTPARAM-39192c48:1471ebc2797:-7da1', NULL, NULL, 'RCOND1441128c:1471efa4c1c:-6c2f', 'BA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1441128c:1471efa4c1c:-6ce5', 'RACT1441128c:1471efa4c1c:-6ce7', 'ACTPARAM-39192c48:1471ebc2797:-7dd8', NULL, NULL, 'RCONST1441128c:1471efa4c1c:-6d47', 'ACTUALUSE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1441128c:1471efa4c1c:-6ce6', 'RACT1441128c:1471efa4c1c:-6ce7', 'ACTPARAM-39192c48:1471ebc2797:-7de1', NULL, NULL, 'RCOND1441128c:1471efa4c1c:-6d84', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-64af', 'RACT17570bc8:16168d77d6c:-64b1', 'ACTPARAM649122d9:1463c83c30a:-7f1e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'advance', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-64b0', 'RACT17570bc8:16168d77d6c:-64b1', 'ACTPARAM1be07afa:1452a9809e9:-694f', NULL, NULL, 'RCOND1e983c10:147f2149816:675', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-65d2', 'RACT17570bc8:16168d77d6c:-65d4', 'ACTPARAM649122d9:1463c83c30a:-7f1e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'previous', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-65d3', 'RACT17570bc8:16168d77d6c:-65d4', 'ACTPARAM1be07afa:1452a9809e9:-694f', NULL, NULL, 'RCOND1e983c10:147f2149816:373', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-66b4', 'RACT17570bc8:16168d77d6c:-66b6', 'ACTPARAM649122d9:1463c83c30a:-7f1e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'current', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT17570bc8:16168d77d6c:-66b5', 'RACT17570bc8:16168d77d6c:-66b6', 'ACTPARAM1be07afa:1452a9809e9:-694f', NULL, NULL, 'RCOND1e983c10:147f2149816:4df', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-2eed', 'RACT1b4af871:14e3cc46e09:-2ef1', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'MV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-2eee', 'RACT1b4af871:14e3cc46e09:-2ef1', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-2eef', 'RACT1b4af871:14e3cc46e09:-2ef1', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'TOTAL_MV', 'TOTAL_MV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-2ef0', 'RACT1b4af871:14e3cc46e09:-2ef1', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST49a3c540:14e51feb8f6:-67ae', 'REFID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-318d', 'RACT1b4af871:14e3cc46e09:-3191', 'ACTPARAM1b4af871:14e3cc46e09:-33b8', NULL, NULL, NULL, NULL, 'BMV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-318e', 'RACT1b4af871:14e3cc46e09:-3191', 'ACTPARAM1b4af871:14e3cc46e09:-341d', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sum', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-318f', 'RACT1b4af871:14e3cc46e09:-3191', 'ACTPARAM1b4af871:14e3cc46e09:-342a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'TOTAL_BMV', 'TOTAL_BMV', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1b4af871:14e3cc46e09:-3190', 'RACT1b4af871:14e3cc46e09:-3191', 'ACTPARAM1b4af871:14e3cc46e09:-343a', NULL, NULL, 'RCONST49a3c540:14e51feb8f6:-6bc7', 'REFID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-6570', 'RACT1e772168:14c5a447e35:-6572', 'ACTPARAM1e772168:14c5a447e35:-66ee', NULL, NULL, NULL, NULL, '@ROUND( DEP, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-6571', 'RACT1e772168:14c5a447e35:-6572', 'ACTPARAM1e772168:14c5a447e35:-66f5', NULL, NULL, 'RCOND1e772168:14c5a447e35:-65bc', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-6cb8', 'RACT1e772168:14c5a447e35:-6cba', 'ACTPARAM1e772168:14c5a447e35:-7e9d', NULL, NULL, NULL, NULL, '@ROUND( MV, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-6cb9', 'RACT1e772168:14c5a447e35:-6cba', 'ACTPARAM1e772168:14c5a447e35:-7ea4', NULL, NULL, 'RCOND1e772168:14c5a447e35:-6cfc', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-7d90', 'RACT1e772168:14c5a447e35:-7d92', 'ACTPARAM1e772168:14c5a447e35:-7ebf', NULL, NULL, NULL, NULL, '@ROUND( BMV, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1e772168:14c5a447e35:-7d91', 'RACT1e772168:14c5a447e35:-7d92', 'ACTPARAM1e772168:14c5a447e35:-7ec6', NULL, NULL, 'RCOND1e772168:14c5a447e35:-7dce', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f7f', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.25', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f80', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f81', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_PREVIOUS_BRGY_SHARE', 'RPT BASIC PREVIOUS BARANGAY SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f82', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCC42bdb818:161e073d7b8:-7ff1', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f83', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'barangay', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-4f84', 'RACT1ef00448:161e1e4995a:-4f85', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC42bdb818:161e073d7b8:-7ff0', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-506c', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.25', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-506d', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-506e', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', 'RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-506f', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCC42bdb818:161e073d7b8:-7fe2', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5070', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'barangay', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5071', 'RACT1ef00448:161e1e4995a:-5072', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC42bdb818:161e073d7b8:-7fe6', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5195', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.25', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5196', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, ' AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5197', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_CURRENT_BRGY_SHARE', 'RPT BASIC CURRENT BARANGAY SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5198', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCC42bdb818:161e073d7b8:-7fd0', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5199', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'barangay', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-519a', 'RACT1ef00448:161e1e4995a:-519b', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC42bdb818:161e073d7b8:-7fd4', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5282', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.25', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5283', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, 'AMOUNT', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5284', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASICINT_CURRENT_BRGY_SHARE', 'RPT BASIC PENALTY CURRENT BARANGAY SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5285', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCC42bdb818:161e073d7b8:-7fc7', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5286', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'barangay', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5287', 'RACT1ef00448:161e1e4995a:-5288', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC42bdb818:161e073d7b8:-7fc6', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5382', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM1ef00448:161e1e4995a:-5473', NULL, NULL, NULL, NULL, '0.25', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5383', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM-78fba29f:161df51b937:-7024', NULL, NULL, NULL, NULL, ' AMOUNT ', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5384', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM-78fba29f:161df51b937:-7031', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'RPT_BASIC_ADVANCE_BRGY_SHARE', 'RPT BASIC ADVANCE BARANGAY SHARE', NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5385', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM-78fba29f:161df51b937:-53f6', NULL, NULL, 'RCC42bdb818:161e073d7b8:-7fbb', 'BRGYID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5386', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM-78fba29f:161df51b937:-7046', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'barangay', NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT1ef00448:161e1e4995a:-5387', 'RACT1ef00448:161e1e4995a:-5388', 'ACTPARAM-78fba29f:161df51b937:-706a', NULL, NULL, 'RC42bdb818:161e073d7b8:-7fba', 'BILLITEM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT37df8403:14c5405fff0:-762c', 'RACT37df8403:14c5405fff0:-762e', 'ACTPARAM6b62feef:14c53ac1f59:-7e90', NULL, NULL, NULL, NULL, '@ROUND( BMV, 0  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT37df8403:14c5405fff0:-762d', 'RACT37df8403:14c5405fff0:-762e', 'ACTPARAM6b62feef:14c53ac1f59:-7e97', NULL, NULL, 'RCOND37df8403:14c5405fff0:-7693', 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-60fc', 'RACT3b800abe:14d2b978f55:-60fe', 'ACTPARAM-2486b0ca:146fff66c3e:-30fe', NULL, NULL, NULL, NULL, '@ROUND(MV, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-60fd', 'RACT3b800abe:14d2b978f55:-60fe', 'ACTPARAM-2486b0ca:146fff66c3e:-3105', NULL, NULL, 'RCOND3b800abe:14d2b978f55:-6196', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-627b', 'RACT3b800abe:14d2b978f55:-627d', 'ACTPARAM-2486b0ca:146fff66c3e:-7994', NULL, NULL, NULL, NULL, '@ROUND( MV , 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-627c', 'RACT3b800abe:14d2b978f55:-627d', 'ACTPARAM-2486b0ca:146fff66c3e:-799f', NULL, NULL, 'RCOND3b800abe:14d2b978f55:-6339', 'BF', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-7c62', 'RACT3b800abe:14d2b978f55:-7c65', 'ACTPARAM-2486b0ca:146fff66c3e:-7204', NULL, NULL, NULL, NULL, '@ROUND(ADJAMOUNT, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-7c63', 'RACT3b800abe:14d2b978f55:-7c65', 'ACTPARAM102ab3e1:147190e9fe4:-f75', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3b800abe:14d2b978f55:-7c64', 'RACT3b800abe:14d2b978f55:-7c65', 'ACTPARAM-2486b0ca:146fff66c3e:-7224', NULL, NULL, 'RCOND3b800abe:14d2b978f55:-7d69', 'ADJ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3de2e0bf:15165926561:-7a67', 'RACT3de2e0bf:15165926561:-7a68', 'ACTPARAM1fcd83ed:149bc7d0f75:-7d25', NULL, NULL, 'RCOND3de2e0bf:15165926561:-7b18', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3fb43b91:14ccf782188:-5ed1', 'RACT3fb43b91:14ccf782188:-5ed3', 'ACTPARAM6b62feef:14c53ac1f59:-7e6d', NULL, NULL, NULL, NULL, '@ROUND( BMV * ADJRATE / 100.0, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT3fb43b91:14ccf782188:-5ed2', 'RACT3fb43b91:14ccf782188:-5ed3', 'ACTPARAM6b62feef:14c53ac1f59:-7e74', NULL, NULL, 'RCOND3fb43b91:14ccf782188:-5fd2', 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT49a3c540:14e51feb8f6:-75aa', 'RACT49a3c540:14e51feb8f6:-75ac', 'ACTPARAM1b4af871:14e3cc46e09:-35ba', NULL, NULL, NULL, NULL, 'TOTALMV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT49a3c540:14e51feb8f6:-75ab', 'RACT49a3c540:14e51feb8f6:-75ac', 'ACTPARAM1b4af871:14e3cc46e09:-35c1', NULL, NULL, 'RCOND49a3c540:14e51feb8f6:-779a', 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT49a3c540:14e51feb8f6:-760e', 'RACT49a3c540:14e51feb8f6:-7610', 'ACTPARAM1b4af871:14e3cc46e09:-35fc', NULL, NULL, NULL, NULL, 'TOTALBMV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT49a3c540:14e51feb8f6:-760f', 'RACT49a3c540:14e51feb8f6:-7610', 'ACTPARAM1b4af871:14e3cc46e09:-3603', NULL, NULL, 'RCOND49a3c540:14e51feb8f6:-779a', 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4bf973aa:1562a233196:-4d24', 'RACT4bf973aa:1562a233196:-4d26', 'ACTPARAM1e772168:14c5a447e35:-66ee', NULL, NULL, NULL, NULL, 'SWORNAMT * DEPRATE / 100', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4bf973aa:1562a233196:-4d25', 'RACT4bf973aa:1562a233196:-4d26', 'ACTPARAM1e772168:14c5a447e35:-66f5', NULL, NULL, 'RCOND4bf973aa:1562a233196:-500e', 'MACH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4e46261d:14f924c6b53:-7b47', 'RACT4e46261d:14f924c6b53:-7b49', 'ACTPARAM-2486b0ca:146fff66c3e:-4090', NULL, NULL, NULL, NULL, '@ROUND( (SWORNAMT + ADJUSTMENT)  * DPRATE / 100.0, 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4e46261d:14f924c6b53:-7b48', 'RACT4e46261d:14f924c6b53:-7b49', 'ACTPARAM-2486b0ca:146fff66c3e:-4351', NULL, NULL, 'RCOND4e46261d:14f924c6b53:-7c57', 'BU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4fc9c2c7:176cac860ed:-74ae', 'RACT4fc9c2c7:176cac860ed:-74b0', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, 'TAX * 0.20', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT4fc9c2c7:176cac860ed:-74af', 'RACT4fc9c2c7:176cac860ed:-74b0', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RCOND4fc9c2c7:176cac860ed:-75f6', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5022d8ba:1589ae965a4:-7a41', 'RACT5022d8ba:1589ae965a4:-7a42', 'ACTPARAM5022d8ba:1589ae965a4:-7aee', NULL, NULL, 'RCOND5022d8ba:1589ae965a4:-7c5c', 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT59614e16:14c5e56ecc8:-7c0a', 'RACT59614e16:14c5e56ecc8:-7c0c', 'ACTPARAM59614e16:14c5e56ecc8:-7f0a', NULL, NULL, NULL, NULL, '@ROUND( BMV - DEP , 2)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT59614e16:14c5e56ecc8:-7c0b', 'RACT59614e16:14c5e56ecc8:-7c0c', 'ACTPARAM59614e16:14c5e56ecc8:-7f11', NULL, NULL, 'RCOND59614e16:14c5e56ecc8:-7c8f', 'MI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT59614e16:14c5e56ecc8:-7d51', 'RACT59614e16:14c5e56ecc8:-7d53', 'ACTPARAM59614e16:14c5e56ecc8:-7f30', NULL, NULL, NULL, NULL, '@ROUND( BMV * DEPRATE / 100 , 0)', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT59614e16:14c5e56ecc8:-7d52', 'RACT59614e16:14c5e56ecc8:-7d53', 'ACTPARAM59614e16:14c5e56ecc8:-7f37', NULL, NULL, 'RCOND59614e16:14c5e56ecc8:-7dcb', 'MI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5a030c2b:17277b1ddc5:-7cec', 'RACT5a030c2b:17277b1ddc5:-7cee', 'ACTPARAM634d9a3c:161503ff1dc:-6f9f', NULL, NULL, NULL, NULL, '0', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5a030c2b:17277b1ddc5:-7ced', 'RACT5a030c2b:17277b1ddc5:-7cee', 'ACTPARAM634d9a3c:161503ff1dc:-6fb7', NULL, NULL, 'RCOND5a030c2b:17277b1ddc5:-7e0f', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b4ac915:147baaa06b4:-6be7', 'RACT5b4ac915:147baaa06b4:-6be9', 'ACTPARAM5b4ac915:147baaa06b4:-6cb3', NULL, NULL, 'RCONST5b4ac915:147baaa06b4:-6d59', 'CLASS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b4ac915:147baaa06b4:-6be8', 'RACT5b4ac915:147baaa06b4:-6be9', 'ACTPARAM5b4ac915:147baaa06b4:-7d98', NULL, NULL, 'RCOND5b4ac915:147baaa06b4:-6da4', 'LA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b84d618:1615428187f:-60d9', 'RACT5b84d618:1615428187f:-60db', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, 'TAX * 0.20', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b84d618:1615428187f:-60da', 'RACT5b84d618:1615428187f:-60db', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RCOND5b84d618:1615428187f:-622b', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b84d618:1615428187f:-658a', 'RACT5b84d618:1615428187f:-658c', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, 'TAX * 0.10', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5b84d618:1615428187f:-658b', 'RACT5b84d618:1615428187f:-658c', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RCOND5b84d618:1615428187f:-66fa', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5d750d7e:161889cc785:-5fbc', 'RACT5d750d7e:161889cc785:-5fbe', 'ACTPARAM5d750d7e:161889cc785:-7bcf', NULL, NULL, NULL, NULL, '@MONTHEND(@DATE(CY, 12, 1)); ', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5d750d7e:161889cc785:-5fbd', 'RACT5d750d7e:161889cc785:-5fbe', 'ACTPARAM5d750d7e:161889cc785:-7bef', NULL, NULL, 'RC-6bcddeab:16188c09983:-7f0b', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5d750d7e:161889cc785:-6d91', 'RACT5d750d7e:161889cc785:-6d93', 'ACTPARAM5d750d7e:161889cc785:-7bcf', NULL, NULL, NULL, NULL, 'if (LAST_YR_PAID + 1 == CY && LAST_QTR_PAID == 4 && CQTR == 1 )\n	return @MONTHEND(@DATE(CY, CQTR*3, 1)); \n\nif (LAST_YR_PAID == CY && LAST_QTR_PAID + 1 == CQTR )\n	return @MONTHEND( @DATE(CY, CQTR*3, 1)); \n\nreturn @MONTHEND( CURRDATE); ', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT5d750d7e:161889cc785:-6d92', 'RACT5d750d7e:161889cc785:-6d93', 'ACTPARAM5d750d7e:161889cc785:-7bef', NULL, NULL, 'RCOND5d750d7e:161889cc785:-6f08', 'BILL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-57c5', 'RACT634d9a3c:161503ff1dc:-57c7', 'ACTPARAM634d9a3c:161503ff1dc:-7848', NULL, NULL, NULL, NULL, 'AV * 0.01', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-57c6', 'RACT634d9a3c:161503ff1dc:-57c7', 'ACTPARAM634d9a3c:161503ff1dc:-7860', NULL, NULL, 'RCOND634d9a3c:161503ff1dc:-586c', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5b7a', 'RACT634d9a3c:161503ff1dc:-5b7d', 'ACTPARAM-5ed6c5b0:16145892be0:-6966', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5b7b', 'RACT634d9a3c:161503ff1dc:-5b7d', 'ACTPARAM-5ed6c5b0:16145892be0:-696d', NULL, NULL, 'RCONST-59249a93:1614f57bd58:-7d28', 'YR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5b7c', 'RACT634d9a3c:161503ff1dc:-5b7d', 'ACTPARAM-5ed6c5b0:16145892be0:-6975', NULL, NULL, 'RCOND-59249a93:1614f57bd58:-7d29', 'AVINFO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5bd8', 'RACT634d9a3c:161503ff1dc:-5bdb', 'ACTPARAM-5ed6c5b0:16145892be0:-7cef', NULL, NULL, NULL, NULL, 'AV', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5bd9', 'RACT634d9a3c:161503ff1dc:-5bdb', 'ACTPARAM-5ed6c5b0:16145892be0:-7cfd', NULL, NULL, 'RCONST-59249a93:1614f57bd58:-7d28', 'YR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT634d9a3c:161503ff1dc:-5bda', 'RACT634d9a3c:161503ff1dc:-5bdb', 'ACTPARAM-5ed6c5b0:16145892be0:-7d06', NULL, NULL, 'RCOND-59249a93:1614f57bd58:-7d29', 'AVINFO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT650f832b:14c53e6ce93:-792e', 'RACT650f832b:14c53e6ce93:-7930', 'ACTPARAM6b62feef:14c53ac1f59:-7e48', NULL, NULL, NULL, NULL, '@ROUND( MV, 0  )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT650f832b:14c53e6ce93:-792f', 'RACT650f832b:14c53e6ce93:-7930', 'ACTPARAM6b62feef:14c53ac1f59:-7e4f', NULL, NULL, 'RCOND650f832b:14c53e6ce93:-79a1', 'PTD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-5d7a', 'RACT6afb50c:1724e644945:-5d7c', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, 'TAX * 0.10', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-5d7b', 'RACT6afb50c:1724e644945:-5d7c', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RCOND6afb50c:1724e644945:-5f45', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-5de6', 'RACT6afb50c:1724e644945:-5de8', 'ACTPARAM634d9a3c:161503ff1dc:-6f9f', NULL, NULL, NULL, NULL, '0', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-5de7', 'RACT6afb50c:1724e644945:-5de8', 'ACTPARAM634d9a3c:161503ff1dc:-6fb7', NULL, NULL, 'RCOND6afb50c:1724e644945:-5f45', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-6088', 'RACT6afb50c:1724e644945:-608a', 'ACTPARAM5b84d618:1615428187f:-68cf', NULL, NULL, NULL, NULL, '0', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6afb50c:1724e644945:-6089', 'RACT6afb50c:1724e644945:-608a', 'ACTPARAM5b84d618:1615428187f:-68e9', NULL, NULL, 'RCOND6afb50c:1724e644945:-6144', 'RLI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6d174068:14e3de9c20b:-7ee9', 'RACT6d174068:14e3de9c20b:-7eeb', 'ACTPARAM1b4af871:14e3cc46e09:-3531', NULL, NULL, NULL, NULL, '@ROUND( MV * AL / 100.0 ,2 )', 'expression', NULL, NULL, NULL, NULL, NULL, NULL);
REPLACE INTO `sys_rule_action_param` (`objid`, `parentid`, `actiondefparam_objid`, `stringvalue`, `booleanvalue`, `var_objid`, `var_name`, `expr`, `exprtype`, `pos`, `obj_key`, `obj_value`, `listvalue`, `lov`, `rangeoption`) VALUES ('RULACT6d174068:14e3de9c20b:-7eea', 'RACT6d174068:14e3de9c20b:-7eeb', 'ACTPARAM1b4af871:14e3cc46e09:-3538', NULL, NULL, 'RCOND6d174068:14e3de9c20b:-7f93', 'MRPU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


set foreign_key_checks = 1
;


alter table rpt_syncdata_forsync add info text
;
alter table rpt_syncdata add info text
;


drop view if exists vw_landtax_lgu_account_mapping
;

CREATE VIEW vw_landtax_lgu_account_mapping 
AS 
select 
    ia.org_objid AS org_objid,
    ia.org_name AS org_name,
    o.orgclass AS org_class,
    p.objid AS parent_objid,
    p.code AS parent_code,
    p.title AS parent_title,
    ia.objid AS item_objid,
    ia.code AS item_code,
    ia.title AS item_title,
    ia.fund_objid AS item_fund_objid,
    ia.fund_code AS item_fund_code,
    ia.fund_title AS item_fund_title,
    ia.type AS item_type,
    pt.tag AS item_tag 
from itemaccount ia 
    inner join itemaccount p on ia.parentid = p.objid 
    inner join itemaccount_tag pt on p.objid = pt.acctid 
    inner join sys_org o on ia.org_objid = o.objid 
where p.state = 'ACTIVE' 
  and ia.state = 'ACTIVE'
;



drop view if exists vw_batchgr
;

create view vw_batchgr 
as 
select 
    bg.objid AS objid,
    bg.state AS state,
    bg.ry AS ry,
    bg.lgu_objid AS lgu_objid,
    bg.barangay_objid AS barangay_objid,
    bg.rputype AS rputype,
    bg.classification_objid AS classification_objid,
    bg.section AS section,
    bg.memoranda AS memoranda,
    bg.txntype_objid AS txntype_objid,
    bg.txnno AS txnno,
    bg.txndate AS txndate,
    bg.effectivityyear AS effectivityyear,
    bg.effectivityqtr AS effectivityqtr,
    bg.originlgu_objid AS originlgu_objid,
    l.name AS lgu_name,
    b.name AS barangay_name,
    b.pin AS barangay_pin,
    pc.name AS classification_name,
    t.objid AS taskid,
    t.state AS taskstate,
    t.assignee_objid AS assignee_objid 
from batchgr bg join sys_org l on bg.lgu_objid = l.objid 
    left join barangay b on bg.barangay_objid = b.objid 
    left join propertyclassification pc on bg.classification_objid = pc.objid 
    left join batchgr_task t on bg.objid = t.refid and t.enddate is null 
;



INSERT INTO `sys_usergroup` (`objid`, `title`, `domain`, `userclass`, `orgclass`, `role`) VALUES ('RPT.RECORD_APPROVER', 'RPT RECORD_APPROVER', 'RPT', NULL, NULL, 'RECORD_APPROVER')
;




INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC PENALTY CURRENT', 'SAN MIGUEL RPT BASIC PENALTY CURRENT', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASICINT_CURRENT', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'POBLACION (123) RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'BALATOHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'BOTON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'BUHI RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'DAYAWA RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'JM ALBERTO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'KATIPUNAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'KILIKILIHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'MABATO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PACOGON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PANGILAO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PARAISO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PROGRESO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'SAN MARCOS RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'SIAY RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'SOLONG RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'TOBREHON RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'OBO RPT BASIC PENALTY CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASICINT_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_CURRENT_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC CURRENT PENALTY PROVINCE SHARE', 'CATANDUANES RPT BASIC CURRENT PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASICINT_CURRENT_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC PENALTY PREVIOUS', 'SAN MIGUEL RPT BASIC PENALTY PREVIOUS', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASICINT_PREVIOUS', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'POBLACION (123) RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'BALATOHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'BOTON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'BUHI RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'DAYAWA RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'JM ALBERTO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'KATIPUNAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'KILIKILIHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'MABATO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PACOGON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PANGILAO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PARAISO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PROGRESO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'SAN MARCOS RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'SIAY RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'SOLONG RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'TOBREHON RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'OBO RPT BASIC PENALTY PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASICINT_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PREVIOUS_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC PREVIOUS PENALTY PROVINCE SHARE', 'CATANDUANES RPT BASIC PREVIOUS PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASICINT_PREVIOUS_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC PENALTY PRIOR', 'SAN MIGUEL RPT BASIC PENALTY PRIOR', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASICINT_PRIOR', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'POBLACION (123) RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'BALATOHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'BOTON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'BUHI RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'DAYAWA RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'JM ALBERTO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'KATIPUNAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'KILIKILIHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'MABATO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PACOGON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PANGILAO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PARAISO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PROGRESO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'SAN MARCOS RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'SIAY RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'SOLONG RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'TOBREHON RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'OBO RPT BASIC PENALTY PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASICINT_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASICINT_PRIOR_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC PRIOR PENALTY PROVINCE SHARE', 'CATANDUANES RPT BASIC PRIOR PENALTY PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASICINT_PRIOR_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC ADVANCE', 'SAN MIGUEL RPT BASIC ADVANCE', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASIC_ADVANCE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC ADVANCE BARANGAY SHARE', 'POBLACION (123) RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC ADVANCE BARANGAY SHARE', 'BALATOHAN RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC ADVANCE BARANGAY SHARE', 'BOTON RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC ADVANCE BARANGAY SHARE', 'BUHI RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC ADVANCE BARANGAY SHARE', 'DAYAWA RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC ADVANCE BARANGAY SHARE', 'JM ALBERTO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC ADVANCE BARANGAY SHARE', 'KATIPUNAN RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC ADVANCE BARANGAY SHARE', 'KILIKILIHAN RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC ADVANCE BARANGAY SHARE', 'MABATO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC ADVANCE BARANGAY SHARE', 'PACOGON RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC ADVANCE BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC ADVANCE BARANGAY SHARE', 'PANGILAO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC ADVANCE BARANGAY SHARE', 'PARAISO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC ADVANCE BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC ADVANCE BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC ADVANCE BARANGAY SHARE', 'PROGRESO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC ADVANCE BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC ADVANCE BARANGAY SHARE', 'SAN MARCOS RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC ADVANCE BARANGAY SHARE', 'SIAY RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC ADVANCE BARANGAY SHARE', 'SOLONG RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC ADVANCE BARANGAY SHARE', 'TOBREHON RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC ADVANCE BARANGAY SHARE', 'OBO RPT BASIC ADVANCE BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASIC_ADVANCE_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_ADVANCE_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC ADVANCE PROVINCE SHARE', 'CATANDUANES RPT BASIC ADVANCE PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASIC_ADVANCE_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC CURRENT', 'SAN MIGUEL RPT BASIC CURRENT', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASIC_CURRENT', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC CURRENT BARANGAY SHARE', 'POBLACION (123) RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC CURRENT BARANGAY SHARE', 'BALATOHAN RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC CURRENT BARANGAY SHARE', 'BOTON RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC CURRENT BARANGAY SHARE', 'BUHI RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC CURRENT BARANGAY SHARE', 'DAYAWA RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC CURRENT BARANGAY SHARE', 'JM ALBERTO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC CURRENT BARANGAY SHARE', 'KATIPUNAN RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC CURRENT BARANGAY SHARE', 'KILIKILIHAN RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC CURRENT BARANGAY SHARE', 'MABATO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC CURRENT BARANGAY SHARE', 'PACOGON RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC CURRENT BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC CURRENT BARANGAY SHARE', 'PANGILAO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC CURRENT BARANGAY SHARE', 'PARAISO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC CURRENT BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC CURRENT BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC CURRENT BARANGAY SHARE', 'PROGRESO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC CURRENT BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC CURRENT BARANGAY SHARE', 'SAN MARCOS RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC CURRENT BARANGAY SHARE', 'SIAY RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC CURRENT BARANGAY SHARE', 'SOLONG RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC CURRENT BARANGAY SHARE', 'TOBREHON RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC CURRENT BARANGAY SHARE', 'OBO RPT BASIC CURRENT BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASIC_CURRENT_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_CURRENT_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC CURRENT PROVINCE SHARE', 'CATANDUANES RPT BASIC CURRENT PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASIC_CURRENT_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC PREVIOUS', 'SAN MIGUEL RPT BASIC PREVIOUS', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASIC_PREVIOUS', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC PREVIOUS BARANGAY SHARE', 'POBLACION (123) RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'BALATOHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC PREVIOUS BARANGAY SHARE', 'BOTON RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC PREVIOUS BARANGAY SHARE', 'BUHI RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC PREVIOUS BARANGAY SHARE', 'DAYAWA RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC PREVIOUS BARANGAY SHARE', 'JM ALBERTO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC PREVIOUS BARANGAY SHARE', 'KATIPUNAN RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'KILIKILIHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC PREVIOUS BARANGAY SHARE', 'MABATO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC PREVIOUS BARANGAY SHARE', 'PACOGON RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC PREVIOUS BARANGAY SHARE', 'PANGILAO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC PREVIOUS BARANGAY SHARE', 'PARAISO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC PREVIOUS BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC PREVIOUS BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC PREVIOUS BARANGAY SHARE', 'PROGRESO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC PREVIOUS BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC PREVIOUS BARANGAY SHARE', 'SAN MARCOS RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC PREVIOUS BARANGAY SHARE', 'SIAY RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC PREVIOUS BARANGAY SHARE', 'SOLONG RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC PREVIOUS BARANGAY SHARE', 'TOBREHON RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC PREVIOUS BARANGAY SHARE', 'OBO RPT BASIC PREVIOUS BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASIC_PREVIOUS_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PREVIOUS_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC PREVIOUS PROVINCE SHARE', 'CATANDUANES RPT BASIC PREVIOUS PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASIC_PREVIOUS_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT BASIC PRIOR', 'SAN MIGUEL RPT BASIC PRIOR', 'REVENUE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_BASIC_PRIOR', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0001', 'ACTIVE', '-', 'POBLACION (123) RPT BASIC PRIOR BARANGAY SHARE', 'POBLACION (123) RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0001', 'POBLACION (123)', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0002', 'ACTIVE', '-', 'BALATOHAN RPT BASIC PRIOR BARANGAY SHARE', 'BALATOHAN RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0002', 'BALATOHAN', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0003', 'ACTIVE', '-', 'BOTON RPT BASIC PRIOR BARANGAY SHARE', 'BOTON RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0003', 'BOTON', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0004', 'ACTIVE', '-', 'BUHI RPT BASIC PRIOR BARANGAY SHARE', 'BUHI RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0004', 'BUHI', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0005', 'ACTIVE', '-', 'DAYAWA RPT BASIC PRIOR BARANGAY SHARE', 'DAYAWA RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0005', 'DAYAWA', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0006', 'ACTIVE', '-', 'JM ALBERTO RPT BASIC PRIOR BARANGAY SHARE', 'JM ALBERTO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0006', 'JM ALBERTO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0007', 'ACTIVE', '-', 'KATIPUNAN RPT BASIC PRIOR BARANGAY SHARE', 'KATIPUNAN RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0007', 'KATIPUNAN', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0008', 'ACTIVE', '-', 'KILIKILIHAN RPT BASIC PRIOR BARANGAY SHARE', 'KILIKILIHAN RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0008', 'KILIKILIHAN', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0009', 'ACTIVE', '-', 'MABATO RPT BASIC PRIOR BARANGAY SHARE', 'MABATO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0009', 'MABATO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0011', 'ACTIVE', '-', 'PACOGON RPT BASIC PRIOR BARANGAY SHARE', 'PACOGON RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0011', 'PACOGON', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0012', 'ACTIVE', '-', 'PAGSANGAHAN RPT BASIC PRIOR BARANGAY SHARE', 'PAGSANGAHAN RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0012', 'PAGSANGAHAN', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0013', 'ACTIVE', '-', 'PANGILAO RPT BASIC PRIOR BARANGAY SHARE', 'PANGILAO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0013', 'PANGILAO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0014', 'ACTIVE', '-', 'PARAISO RPT BASIC PRIOR BARANGAY SHARE', 'PARAISO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0014', 'PARAISO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0015', 'ACTIVE', '-', 'PATAGAN SALVACION RPT BASIC PRIOR BARANGAY SHARE', 'PATAGAN SALVACION RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0015', 'PATAGAN SALVACION', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0016', 'ACTIVE', '-', 'PATAGAN STA ELENA RPT BASIC PRIOR BARANGAY SHARE', 'PATAGAN STA ELENA RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0016', 'PATAGAN STA ELENA', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0017', 'ACTIVE', '-', 'PROGRESO RPT BASIC PRIOR BARANGAY SHARE', 'PROGRESO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0017', 'PROGRESO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0018', 'ACTIVE', '-', 'SAN JUAN (AROYAO) RPT BASIC PRIOR BARANGAY SHARE', 'SAN JUAN (AROYAO) RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0018', 'SAN JUAN (AROYAO)', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0019', 'ACTIVE', '-', 'SAN MARCOS RPT BASIC PRIOR BARANGAY SHARE', 'SAN MARCOS RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0019', 'SAN MARCOS', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0020', 'ACTIVE', '-', 'SIAY RPT BASIC PRIOR BARANGAY SHARE', 'SIAY RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0020', 'SIAY', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0021', 'ACTIVE', '-', 'SOLONG RPT BASIC PRIOR BARANGAY SHARE', 'SOLONG RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0021', 'SOLONG', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-0022', 'ACTIVE', '-', 'TOBREHON RPT BASIC PRIOR BARANGAY SHARE', 'TOBREHON RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-0022', 'TOBREHON', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_BRGY_SHARE:027-09-010', 'ACTIVE', '-', 'OBO RPT BASIC PRIOR BARANGAY SHARE', 'OBO RPT BASIC PRIOR BARANGAY SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027-09-010', 'OBO', 'RPT_BASIC_PRIOR_BRGY_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_BASIC_PRIOR_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT BASIC PRIOR PROVINCE SHARE', 'CATANDUANES RPT BASIC PRIOR PROVINCE SHARE', 'PAYABLE', 'GENERAL', '01', 'GENERAL', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_BASIC_PRIOR_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_CURRENT:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF PENALTY CURRENT', 'SAN MIGUEL RPT SEF PENALTY CURRENT', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEFINT_CURRENT', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_CURRENT_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF CURRENT PENALTY PROVINCE SHARE', 'CATANDUANES RPT SEF CURRENT PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEFINT_CURRENT_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_PREVIOUS:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF PENALTY PREVIOUS', 'SAN MIGUEL RPT SEF PENALTY PREVIOUS', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEFINT_PREVIOUS', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_PREVIOUS_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF PREVIOUS PENALTY PROVINCE SHARE', 'CATANDUANES RPT SEF PREVIOUS PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEFINT_PREVIOUS_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_PRIOR:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF PENALTY PRIOR', 'SAN MIGUEL RPT SEF PENALTY PRIOR', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEFINT_PRIOR', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEFINT_PRIOR_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF PRIOR PENALTY PROVINCE SHARE', 'CATANDUANES RPT SEF PRIOR PENALTY PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEFINT_PRIOR_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_ADVANCE:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF ADVANCE', 'SAN MIGUEL RPT SEF ADVANCE', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEF_ADVANCE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_ADVANCE_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF ADVANCE PROVINCE SHARE', 'CATANDUANES RPT SEF ADVANCE PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEF_ADVANCE_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_CURRENT:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF CURRENT', 'SAN MIGUEL RPT SEF CURRENT', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEF_CURRENT', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_CURRENT_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF CURRENT PROVINCE SHARE', 'CATANDUANES RPT SEF CURRENT PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEF_CURRENT_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_PREVIOUS:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF PREVIOUS', 'SAN MIGUEL RPT SEF PREVIOUS', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEF_PREVIOUS', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_PREVIOUS_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF PREVIOUS PROVINCE SHARE', 'CATANDUANES RPT SEF PREVIOUS PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEF_PREVIOUS_PROVINCE_SHARE', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_PRIOR:02709', 'ACTIVE', '-', 'SAN MIGUEL RPT SEF PRIOR', 'SAN MIGUEL RPT SEF PRIOR', 'REVENUE', 'SEF', '02', 'SEF', '0.00', 'ANY', '02709', 'SAN MIGUEL', 'RPT_SEF_PRIOR', '0', '0', '0');
INSERT INTO `itemaccount` (`objid`, `state`, `code`, `title`, `description`, `type`, `fund_objid`, `fund_code`, `fund_title`, `defaultvalue`, `valuetype`, `org_objid`, `org_name`, `parentid`, `generic`, `sortorder`, `hidefromlookup`) VALUES ('RPT_SEF_PRIOR_PROVINCE_SHARE:027', 'ACTIVE', '-', 'CATANDUANES RPT SEF PRIOR PROVINCE SHARE', 'CATANDUANES RPT SEF PRIOR PROVINCE SHARE', 'PAYABLE', 'SEF', '02', 'SEF', '0.00', 'ANY', '027', 'CATANDUANES', 'RPT_SEF_PRIOR_PROVINCE_SHARE', '0', '0', '0');


