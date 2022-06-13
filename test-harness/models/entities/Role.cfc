component persistent="true" table="roles" {

	property
		name     ="roleID"
		column   ="roleID"
		fieldType="id"
		generator="native";
	property name="role";

	// O2M -> Users
	property
		name        ="users"
		singularName="user"
		fieldtype   ="one-to-many"
		type        ="array"
		lazy        ="extra"
		cfc         ="User"
		fkcolumn    ="FKRoleID"
		inverse     ="true"
		cascade     ="all-delete-orphan";

	// M20 -> Category
	property
		name     ="category"
		cfc      ="Category"
		fieldtype="many-to-one"
		fkcolumn ="FKCategoryID"
		lazy     ="true"
		notnull  ="false";

	// M20 -> Permission
	property
		name     ="permission"
		cfc      ="Permission"
		fieldtype="many-to-one"
		fkcolumn ="FKPermissionID"
		lazy     ="true"
		notnull  ="false";

	this.constraints = { "role" : { required : true } };

}
