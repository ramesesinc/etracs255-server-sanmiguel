use etracs255_sanmiguel;

drop table if exists ztmp_purchase_receipt 
;
create table ztmp_purchase_receipt 
select 
	a.afid, a.dtfiled, a.startseries, a.endseries, a.currentseries, 
	d.receivedstartseries, d.receivedendseries, d.controlid, a.currentdetailid  
from af_control a 
	inner join af_control_detail d on d.objid = a.currentdetailid  
	inner join afunit u on (u.itemid = a.afid and u.unit = a.unit) 
	inner join af on af.objid = a.afid 
where d.reftype = 'PURCHASE_RECEIPT' 
	and af.formtype = 'serial' 
	and a.startseries <> d.receivedstartseries 
order by a.afid, a.dtfiled, a.startseries 
; 
update 
	af_control_detail aa, ztmp_purchase_receipt zz 
set 
	aa.receivedstartseries = zz.startseries, 
	aa.receivedendseries = zz.endseries, 
	aa.beginstartseries = null, 
	aa.beginendseries = null, 
	aa.issuedstartseries = null, 
	aa.issuedendseries = null, 
	aa.endingstartseries = zz.startseries, 
	aa.endingendseries = zz.endseries, 
	aa.qtyreceived = (zz.endseries - zz.startseries + 1), 
	aa.qtybegin = 0, aa.qtyissued = 0, aa.qtycancelled = 0, 
	aa.qtyending = (zz.endseries - zz.startseries + 1) 
where 
	aa.objid = zz.currentdetailid
; 
drop table if exists ztmp_purchase_receipt 
;


drop table if exists ztmp_issue 
;
create table ztmp_issue 
select 
	a.afid, a.dtfiled, a.startseries, a.endseries, a.currentseries, 
	d.receivedstartseries, d.receivedendseries, d.controlid, a.currentdetailid  
from af_control a 
	inner join af_control_detail d on d.objid = a.currentdetailid  
	inner join afunit u on (u.itemid = a.afid and u.unit = a.unit) 
	inner join af on af.objid = a.afid 
where d.reftype = 'ISSUE' 
	and af.formtype = 'serial' 
	and a.startseries <> d.receivedstartseries 
order by a.afid, a.dtfiled, a.startseries 
; 
update 
	af_control_detail aa, ztmp_issue zz 
set 
	aa.receivedstartseries = zz.startseries, 
	aa.receivedendseries = zz.endseries, 
	aa.beginstartseries = null, 
	aa.beginendseries = null, 
	aa.issuedstartseries = null, 
	aa.issuedendseries = null, 
	aa.endingstartseries = zz.startseries, 
	aa.endingendseries = zz.endseries, 
	aa.qtyreceived = (zz.endseries - zz.startseries + 1), 
	aa.qtybegin = 0, aa.qtyissued = 0, aa.qtycancelled = 0, 
	aa.qtyending = (zz.endseries - zz.startseries + 1) 
where 
	aa.objid = zz.currentdetailid
; 
drop table if exists ztmp_issue 
;



drop table if exists ztmp_purchase_receipt 
;
create table ztmp_purchase_receipt 
select 
	a.afid, a.dtfiled, a.startseries, a.endseries, a.currentseries, 
	d.receivedstartseries, d.receivedendseries, d.controlid, a.currentdetailid  
from af_control a 
	inner join af_control_detail d on d.objid = a.currentdetailid  
	inner join afunit u on (u.itemid = a.afid and u.unit = a.unit) 
	inner join af on af.objid = a.afid 
where d.reftype = 'PURCHASE_RECEIPT' 
	and af.formtype <> 'serial' 
	and a.startseries <> d.receivedstartseries 
order by a.afid, a.dtfiled, a.startseries 
; 
update 
	af_control_detail aa, ztmp_purchase_receipt zz 
set 
	aa.receivedstartseries = zz.startseries, 
	aa.receivedendseries = zz.endseries, 
	aa.beginstartseries = null, 
	aa.beginendseries = null, 
	aa.issuedstartseries = null, 
	aa.issuedendseries = null, 
	aa.endingstartseries = zz.startseries, 
	aa.endingendseries = zz.endseries, 
	aa.qtyreceived = (zz.endseries - zz.startseries + 1), 
	aa.qtybegin = 0, aa.qtyissued = 0, aa.qtycancelled = 0, 
	aa.qtyending = (zz.endseries - zz.startseries + 1) 
where 
	aa.objid = zz.currentdetailid
; 
drop table if exists ztmp_purchase_receipt 
;



drop table if exists ztmp_issue 
;
create table ztmp_issue 
select 
	a.afid, a.dtfiled, a.startseries, a.endseries, a.currentseries, 
	d.receivedstartseries, d.receivedendseries, d.controlid, a.currentdetailid  
from af_control a 
	inner join af_control_detail d on d.objid = a.currentdetailid  
	inner join afunit u on (u.itemid = a.afid and u.unit = a.unit) 
	inner join af on af.objid = a.afid 
where d.reftype = 'ISSUE' 
	and af.formtype <> 'serial' 
	and a.startseries <> d.receivedstartseries 
order by a.afid, a.dtfiled, a.startseries 
; 
update 
	af_control_detail aa, ztmp_issue zz 
set 
	aa.receivedstartseries = zz.startseries, 
	aa.receivedendseries = zz.endseries, 
	aa.beginstartseries = null, 
	aa.beginendseries = null, 
	aa.issuedstartseries = null, 
	aa.issuedendseries = null, 
	aa.endingstartseries = zz.startseries, 
	aa.endingendseries = zz.endseries, 
	aa.qtyreceived = (zz.endseries - zz.startseries + 1), 
	aa.qtybegin = 0, aa.qtyissued = 0, aa.qtycancelled = 0, 
	aa.qtyending = (zz.endseries - zz.startseries + 1) 
where 
	aa.objid = zz.currentdetailid
; 
drop table if exists ztmp_issue 
;
