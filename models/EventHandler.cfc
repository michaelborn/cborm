﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Generic Hibernate Event Handler that ties to the ColdBox proxy for ColdBox Operations.
 * This is just a base class you can inherit from to give you access to your ColdBox
 * Application and the CF9 ORM event handler methods. Then you just need to
 * use a la carte.
 *
 * We also execute interception points that match the ORM events so you can eaisly
 * chain ORM interceptions.
 *
 */
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler" {

	/**
	 * preLoad called by hibernate which in turn announces a coldbox interception: ORMPreLoad
	 */
	public void function preLoad( any entity ){
		announceInterception(
			"ORMPreLoad",
			{ entity : arguments.entity }
		);
	}

	/**
	 * postLoad called by hibernate which in turn announces a coldbox interception: ORMPostLoad
	 */
	public void function postLoad( any entity ){
		var args = {
			entity     : arguments.entity,
			entityName : ""
		};

		// Short-cut discovery via ActiveEntity
		if ( structKeyExists( arguments.entity, "getEntityName" ) ) {
			args.entityName = arguments.entity.getEntityName();
		} else {
			// it must be in session.
			args.entityName = ormGetSession().getEntityName( arguments.entity );
		}

		processEntityInjection( args.entityName, args.entity );

		announceInterception( "ORMPostLoad", args );
	}

	/**
	 * postDelete called by hibernate which in turn announces a coldbox interception: ORMPostDelete
	 */
	public void function postDelete( any entity ){
		announceInterception(
			"ORMPostDelete",
			{ entity : arguments.entity }
		);
	}

	/**
	 * preDelete called by hibernate which in turn announces a coldbox interception: ORMPreDelete
	 */
	public void function preDelete( any entity ){
		announceInterception(
			"ORMPreDelete",
			{ entity : arguments.entity }
		);
	}

	/**
	 * preUpdate called by hibernate which in turn announces a coldbox interception: ORMPreUpdate
	 */
	public void function preUpdate( any entity, Struct oldData = {} ){
		announceInterception(
			"ORMPreUpdate",
			{
				entity  : arguments.entity,
				oldData : arguments.oldData
			}
		);
	}

	/**
	 * postUpdate called by hibernate which in turn announces a coldbox interception: ORMPostUpdate
	 */
	public void function postUpdate( any entity ){
		announceInterception(
			"ORMPostUpdate",
			{ entity : arguments.entity }
		);
	}

	/**
	 * preInsert called by hibernate which in turn announces a coldbox interception: ORMPreInsert
	 */
	public void function preInsert( any entity ){
		announceInterception(
			"ORMPreInsert",
			{ entity : arguments.entity }
		);
	}

	/**
	 * postInsert called by hibernate which in turn announces a coldbox interception: ORMPostInsert
	 */
	public void function postInsert( any entity ){
		announceInterception(
			"ORMPostInsert",
			{ entity : arguments.entity }
		);
	}

	/**
	 * preSave called by ColdBox Base service before save() calls
	 */
	public void function preSave( any entity ){
		announceInterception(
			"ORMPreSave",
			{ entity : arguments.entity }
		);
	}

	/**
	 * postSave called by ColdBox Base service after transaction commit or rollback via the save() method
	 */
	public void function postSave( any entity ){
		announceInterception(
			"ORMPostSave",
			{ entity : arguments.entity }
		);
	}

	/**
	 * Called when the session is dirty-checked
	 * Lucee with Hibernate 5.4+ ONLY
	 */
	public void function onDirtyCheck( dirtyCheckEvent ){
		announceInterception(
			"ORMDirtyCheck",
			{ event : arguments.dirtyCheckEvent }
		);
	}

	/**
	 * Called when a session entity is evicted
	 * Lucee with Hibernate 5.4+ ONLY
	 */
	public void function onEvict( evictEvent ){
		announceInterception(
			"ORMEvict",
			{ event : arguments.evictEvent }
		);
	}

	/**
	 * Called when the session is cleared
	 * Lucee with Hibernate 5.4+ ONLY
	 */
	public void function onClear( clearEvent ){
		announceInterception(
			"ORMClear",
			{ event : arguments.clearEvent }
		);
	}

	/**
	 * Called when the session is flushed
	 * Lucee with Hibernate 5.4+ ONLY
	 */
	public void function onFlush( flushEvent ){
		announceInterception(
			"ORMFlush",
			{ event : arguments.flushEvent }
		);
	}

	/**
	 * Called on the automatic flushing of the session
	 * Lucee with Hibernate 5.4+ ONLY
	 */
	public void function onAutoFlush( autoFlushEvent ){
		announceInterception(
			"ORMAutoFlush",
			{ event : arguments.autoFlushEvent }
		);
	}

	/**
	 * Called before the session is flushed.
	 */
	public void function preFlush( any entities ){
		announceInterception(
			"ORMPreFlush",
			{ entities : arguments.entities }
		);
	}

	/**
	 * Called after the session is flushed.
	 */
	public void function postFlush( any entities ){
		announceInterception(
			"ORMPostFlush",
			{ entities : arguments.entities }
		);
	}

	/**
	 * postNew called by ColdBox which in turn announces a coldbox interception: ORMPostNew
	 */
	public void function postNew( any entity, any entityName ){
		var args = {
			entity     : arguments.entity,
			entityName : ""
		};

		// Do we have an incoming name
		if ( !isNull( arguments.entityName ) && len( arguments.entityName ) ) {
			args.entityName = arguments.entityName;
		}

		// If we don't have the entity name, then look it up
		if ( !len( args.entityName ) ) {
			// Short-cut discovery via ActiveEntity
			if ( structKeyExists( arguments.entity, "getEntityName" ) ) {
				args.entityName = arguments.entity.getEntityName();
			} else {
				// Long Discovery
				var md          = getMetadata( arguments.entity );
				args.entityName = ( md.keyExists( "entityName" ) ? md.entityName : listLast( md.name, "." ) );
			}
		}

		// Process the announcement
		announceInterception( "ORMPostNew", args );
	}

	/**
	 * Get the system Event Manager
	 */
	public any function getEventManager(){
		return getWireBox().getEventManager();
	}

	/**
	 * process entity injection
	 *
	 * @entityName the entity to process, we use hash codes to identify builders
	 * @entity The entity object
	 *
	 * @return The processed entity
	 */
	public function processEntityInjection( required entityName, required entity ){
		var ormSettings     = getController().getConfigSettings().modules[ "cborm" ].settings;
		var injectorInclude = ormSettings.injection.include;
		var injectorExclude = ormSettings.injection.exclude;

		// Enabled?
		if ( NOT ormSettings.injection.enabled ) {
			return arguments.entity;
		}

		// Include,Exclude?
		if (
			(
				len( injectorInclude ) AND listContainsNoCase(
					injectorInclude,
					arguments.entityName
				)
			)
			OR
			(
				len( injectorExclude ) AND NOT listContainsNoCase(
					injectorExclude,
					arguments.entityName
				)
			)
			OR
			( NOT len( injectorInclude ) AND NOT len( injectorExclude ) )
		) {
			// Process DI
			getWireBox().autowire(
				target   = arguments.entity,
				targetID = "ORMEntity-#arguments.entityName#"
			);
		}

		return arguments.entity;
	}

}
