/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package de.axelspringer.videoplayer.vast.parser.base
{
	import de.axelspringer.videoplayer.vast.model.VASTUrl;
	
	/**
	 * Internal non-linear element parser and data object
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2NonLinearElement extends VAST2Element
	{
		/* All these variables are references or arrays of references */
		private var _id:String;
		private var _duration:String;	// sevenOne custom functionality
		private var _minSuggestedDuration:String;	// new! 07.02.2013
		private var _width:Number;
		private var _height:Number;
		private var _expandedWidth:Number;
		private var _expandedHeight:Number;
		/* NO LONGER USED
		private var _resourceType:String;
		private var _creativeType:String; */
		private var _scalable:Boolean;
		private var _maintainAspectRatio:Boolean;
		private var _staticResource:String;
		private var _iframeResource:String;
		private var _htmlResource:String;
		private var _staticResourceCreativeType:String;
		/* NO LONGER USED
		private var _URL:String;
		private var _Code:String; */
		private var _AltText:String;
		private var _apiFramework:String;
		private var _adParameters:String;
		private var _NonLinearClickThrough:String;
		private var _clickTrackings:Array;
	
		/**
		 * @private
		 */	
		public function VAST2NonLinearElement(forxData:Object, trackingData:VAST2TrackingData)	
		{
			super(forxData,"VAST2NonLinearElement", trackingData);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " created", "Instream", elementName); 
			_id = "";
			_duration = "";
			_minSuggestedDuration = "";
			_width = new Number();
			_height = new Number();
			_expandedWidth = new Number();
			_expandedHeight = new Number();
			/* NO LONGER USED
			_resourceType = "";
			_creativeType = ""; */
			_scalable = new Boolean();
			_maintainAspectRatio = new Boolean();
			_staticResource = new String();
			_iframeResource = new String();
			_htmlResource = new String();
			_staticResourceCreativeType = new String();
			/* _URL = ""; NO LONGER USED */
			/* _Code = ""; NO LONGER USED */
			_NonLinearClickThrough = new String();
			_clickTrackings = new Array();
			_apiFramework = new String();
			_adParameters = new String();
			
			if ( forxData == null || trackingData == null)
			{
				//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " is just a temporary placeholder.", "Instream", elementName); 	
				return;		// Just a placeholder object to prevent null reference errors
			}
		}

		/**
		 * @private
		 */	
		public function parseXMLData() : void
		{	
			var i:Number;
			if (forxRef == null)
				return;
			if (forxRef.@id != undefined) _id = forxRef.@id;
			if (forxRef.@duration != undefined) _duration = forxRef.@duration;
			if (forxRef.@minSuggestedDuration != undefined) _minSuggestedDuration = forxRef.@minSuggestedDuration;
			if (forxRef.@width != undefined) _width = forxRef.@width;
			if (forxRef.@height != undefined) _height = forxRef.@height;
			if (forxRef.@expandedWidth != undefined) _expandedWidth = forxRef.@expandedWidth;
			if (forxRef.@expandedHeight != undefined) _expandedHeight = forxRef.@expandedHeight;
		/*	if (forxRef.@resourceType != undefined) _resourceType = forxRef.@resourceType; NO LONGER USED*/
		/*	if (forxRef.@creativeType != undefined) _creativeType = forxRef.StaticResource.@creativeType; */
			if (forxRef.@scalable != undefined) _scalable = forxRef.@scalable;
			if (forxRef.@maintainAspectRatio != undefined) _maintainAspectRatio = forxRef.@maintainAspectRatio.text();
			/*if (forxRef.URL != undefined) _URL = forxRef.URL; NO LONGER USED */
			/* if (forxRef.Code != undefined) _Code = forxRef.Code; NO LONGER USED */
			if (forxRef.NonLinearClickThrough != undefined) _NonLinearClickThrough = forxRef.NonLinearClickThrough.text();
			if (forxRef.ClickTracking != undefined) _clickTrackings = parseURLTags(forxRef.ClickTracking);
			if (forxRef.AltText != undefined) _AltText = forxRef.AltText.text();
			if (forxRef.@apiFramework != undefined ) _apiFramework = forxRef.@apiFramework;
			if (forxRef.StaticResource != undefined ) _staticResource = forxRef.StaticResource.text()
			if (forxRef.StaticResource.@creativeType != undefined ) _staticResourceCreativeType = forxRef.StaticResource.@creativeType;
			if (forxRef.IFrameResource != undefined ) _iframeResource = forxRef.IFrameResource.text();
			if (forxRef.HTMLResource != undefined ) _htmlResource = forxRef.HTMLResource.text();
			if (forxRef.AdParameters != undefined ) _adParameters = forxRef.AdParameters.text();
			
		}
		
		
		private function parseURLTags(xmlList:XMLList):Array
		{
			var urls:Array = new Array();
			
			for (var i:int = 0; i < xmlList.length(); i++) 
			{
				var child:XML = xmlList[i];
				
				switch(child.nodeKind()) 
				{
					case "element":
					{
						switch (child.localName()) 
						{
							case "ClickTracking":
								urls.push( new VASTUrl( parseURL( child ) ) );
								break;
							default:
								trace("[VAST] parseURLTags() - Unsupported VAST tag: " + child.localName());
								break;								
						}
						break;
					}
				}
			}
			return urls;
		}
		
		private function parseURL(xml:XML):String
		{
			var child:String = xml.children()[0];
			if (child != null)
			{
				// Strip all leading and trailing whitespace.
				child = child.replace(/^\s*|\s*$/g, "");
				if (child.length == 0)
				{
					child = null;
				}
			}
			
			return child;
		}

		/**
		 * @private
		 */	
		public function get id():String {return _id;}
		/**
		 * @private
		 */	
		public function get duration():String {return _duration;}
		
		public function get minSuggestedDuration():String {return _minSuggestedDuration;}
		/**
		 * @private
		 */	
		public function get width():Number {return _width;}
		/**
		 * @private
		 */	
		public function get height():Number {return _height;}
		/**
		 * @private
		 */	
		public function get expandedWidth():Number {return _expandedWidth;}
		/**
		 * @private
		 */	
		public function get expandedHeight():Number {return _expandedHeight;}
		/**
		 * @private
		 */	
		public function get resourceType():String {return "";}  // NO LONGER USED
		/**
		 * @private
		 */	
		public function get creativeType():String {return staticResourceCreativeType;} // DEPRECATED. USE staticResourceCreativeType
		/**
		 * @private
		 */	
		public function get URL():String {return staticResource;} // DEPRECATED. USE staticResource
		/**
		 * @private
		 */	
		public function get scalable():Boolean {return _scalable;}
		/**
		 * @private
		 */	
		public function get maintainAspectRatio():Boolean {return _maintainAspectRatio;}
		/**
		 * @private
		 */	
		public function get Code():String {return "";} // NO LONGER USED
		/**
		 * @private
		 */	
		public function get nonLinearClickThrough():String {return _NonLinearClickThrough;}
		
		public function get clickTrackings() :Array { return _clickTrackings; }
		/**
		 * @private
		 */	
		public function get apiFramework():String {return _apiFramework;}
		/**
		 * @private
		 */	
		public function get staticResource():String {return _staticResource;}
		/**
		 * @private
		 */	
		public function get staticResourceCreativeType():String { return _staticResourceCreativeType;}
		/**
		 * @private
		 */	
		public function get iframeResource():String {return _iframeResource };
		/**
		 * @private
		 */	
		public function get htmlResource():String { return _htmlResource};
		/**
		 * @private
		 */	
		public function get adParameters():String { return _adParameters};	 
	}
}
