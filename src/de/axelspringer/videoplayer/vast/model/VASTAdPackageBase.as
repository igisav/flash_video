/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*  Contributor(s): Adobe Systems Inc.
* 
*****************************************************/
package de.axelspringer.videoplayer.vast.model
{
	/**
	 * Base class for the top-level VAST ad packages (inline ads and wrapper ads).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTAdPackageBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTAdPackageBase()
		{
			_errors = new Array();
			_impressions = new Array();
			_trackingEvents = new Array();
			_extensions = new Array(); 
		}

		/**
		 * Indicates source ad server.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adSystem():String 
		{
			return _adSystem;
		}
		
		public function set adSystem(value:String):void 
		{
			_adSystem = value;
		}
		
		/**
		 * duration set in <Video> Node, used as duration of NonLinear ads (sevenone custom functionality)
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get duration():String
		{
			return _duration;
		}

		public function set duration(value:String):void 
		{
			_duration = value;
		}
		
		/**
		 * URLs to track playing error.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get errors():Array 
		{
			return _errors;
		}
		
		/**
		 * Adds the given VASTUrl to this ad package as an error.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addError(value:VASTUrl):void 
		{
			_errors.push(value);
		}
		
		/**
		 * Adds the given XML Object to this ad package's extensions.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addExtension(value:Object):void 
		{
			_extensions.push(value);
		}
		
		/**
		 * URLs to track impression.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get impressions():Array
		{
			return _impressions;
		}

		/**
		 * Adds the given VASTUrl to this ad package as an impression.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addImpression(value:VASTUrl):void 
		{
			_impressions.push(value);
		}

		/**
		 * Tracking events associated with this ad package.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trackingEvents():Array
		{
			return _trackingEvents;
		}
		
		/**
		 * Returns the VASTTrackingEvent with the given event type, null if no
		 * such tracking event exists.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getTrackingEventByType(eventType:VASTTrackingEventType):VASTTrackingEvent
		{
			for each (var trackingEvent:VASTTrackingEvent in _trackingEvents)
			{
				if (trackingEvent.type == eventType)
				{
					return trackingEvent;
				}
			}
			
			return null;
		}
		
		/**
		 * Extension elements in the VAST document allow for customization or
		 * for ad server specific features (e.g. geo data, unique identifiers).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get extensions():Array
		{
			return _extensions;
		}
		
		/**
		 * Adds the given VASTTrackingEvent to this ad package.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addTrackingEvent(value:VASTTrackingEvent):void 
		{
			_trackingEvents.push(value);
		}
		
		private var _adSystem:String;
		private var _errors:Array;
		private var _trackingEvents:Array;
		private var _extensions:Array;
		private var _impressions:Array;
		private var _duration:String;
	}
}