component
	persistent="true"
	table     ="permissions"
	extends   ="Abstract"
	cachename ="permissions"
	cacheuse  ="read-write"
	datasource="coolblog"
{

	property
		name     ="id"
		column   ="permission_id"
		fieldType="id"
		generator="uuid";
	property name="permission"    notnull="true";
	property name="description" notnull="true";
	property
		name   ="modifydate"
		insert ="false"
		update ="false"
		ormtype="timestamp";

	function init(){
		this.created = now();
	}

}
