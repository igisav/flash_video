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
package de.axelspringer.videoplayer.vast.model
{
	import de.axelspringer.videoplayer.vast.parser.VAST2Parser;
	
	import flash.events.*;
	
	/**
	 * Deserializes the parser variables for the VAST modules.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	public dynamic class VAST2Translator extends VASTDataObject
	{
		// Static vars also need to be replicated in ../../VAST2Translator.as legacy file since static vars can't be inherited
		public static const TRANSLATOR_READY:String = "translatorReady";
		
		public static const PLACEMENT_LINEAR:String = "Linear";
		public static const PLACEMENT_NONLINEAR:String = "NonLinear";
				
		private var _adPlacement:String;
		
		private var _adTagID:String;
		private var _adTagWrapperSystem:String;
		private var _VASTAdTagURL:String;

		private var _adTagSystem:String;
		private var _adTagTitle:String;
		private var _adTagImpressionURL:String;
		private var _adTagVASTDuration:Number;
		private var _clickThruUrl:String;
		private var _adParameters:String;
		
		private var _trackingArray:Array;
		private var _adTagTrackingEvent:Array;
		
		private var _impressionArray : Array;
		private var _errorArray : Array;
		private var _extensionsArray : Array;
		private var _surveyArray : Array;
		private var _clickThruArray : Array;
		private var _mediafileArray:Array;
		private var _companionArray:Array;
		private var _nonlinearArray:Array;

		
		private var _vastObj:VAST2Parser;
		private var _vastVars:Object;
		
		private var _trkCreativeViewEvent:Array;
		private var _trkStartEvent:Array;
		private var _trkMidPointEvent:Array;
		private var _trkFirstQuartileEvent:Array;
		private var _trkThirdQuartileEvent:Array;
		private var _trkCompleteEvent:Array;
		private var _trkMuteEvent:Array;
		private var _trkUnmuteEvent:Array; 
		private var _trkPauseEvent:Array;
		private var _trkFullScreenEvent:Array;
		private var _trkClickThruEvent:Array;
		private var _trkCloseEvent:Array;
		private var _trkRewindEvent:Array;
		private var _trkResumeEvent:Array;
		private var _trkExpandEvent:Array;
		private var _trkCollapseEvent:Array;
		private var _trkAcceptInvitationEvent:Array;
		
		//Nonlinear
		private var _clickThruUrlNonLinear:String;
		
		private var _trkCreativeViewEventNonLinear:Array;
		private var _trkStartEventNonLinear:Array;
		private var _trkMidPointEventNonLinear:Array;
		private var _trkFirstQuartileEventNonLinear:Array;
		private var _trkThirdQuartileEventNonLinear:Array;
		private var _trkCompleteEventNonLinear:Array;
		private var _trkMuteEventNonLinear:Array;
		private var _trkUnmuteEventNonLinear:Array;
		private var _trkPauseEventNonLinear:Array;
		private var _trkFullScreenEventNonLinear:Array;
		private var _trkCloseEventNonLinear:Array;
		private var _trkClickThruEventNonLinear:Array;
		private var _trkRewindEventNonLinear:Array;
		private var _trkResumeEventNonLinear:Array;
		private var _trkExpandEventNonLinear:Array;
		private var _trkCollapseEventNonLinear:Array;
		private var _trkAcceptInvitationEventNonLinear:Array;	
		
		// collected trackings as VOs
		public var trackingEventsLinear:Array;	
		public var trackingEventsNonLinear:Array;	
	/**
	 * Constructor
	 * 
	 * @param parser VAST2Parser
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */				
		public function VAST2Translator(parser:VAST2Parser, placement:String = PLACEMENT_LINEAR):void
		{
			super(VASTDataObject.VERSION_2_0);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Init VAST2Translator", "Instream", "VAST2Translator");
			_vastObj = parser;
			adPlacement = placement; // Use setter to add sanity checking
			deserializeVastVars();
			
		}
	/**
	 * Deserialize VAST variables into data arrays.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */			
		public function deserializeVastVars():void
		{
			
			//UIFDebugMessage.getInstance()._debugMessage(3, "In deserializeVastVars() ", "Instream", "VAST2Translator");
			
			
			if(_vastObj.adTagWrapperSystem != null && _vastObj.adTagWrapperSystem != "")
			{
				_adTagWrapperSystem = String(_vastObj.adTagWrapperSystem);
			}
			
			if(_vastObj.VASTAdTagURL != null && _vastObj.VASTAdTagURL != "")
			{
				_VASTAdTagURL = String(_vastObj.VASTAdTagURL);
			}
	
			if(_vastObj.adTagID != null && _vastObj.adTagID != "")
			{
				_adTagID = String(_vastObj.adTagID);
			}
			
			if(_vastObj.adTagSystem != null && _vastObj.adTagSystem != "")
			{
				_adTagSystem = String(_vastObj.adTagSystem);
			}
			
			if(_vastObj.adTagTitle != null && _vastObj.adTagTitle != "")
			{
				_adTagTitle = String(_vastObj.adTagTitle);
			}												
			
			//_adTagWrapperImpression = String(_vastObj.adTagWrapperImpression );
			
			if(_vastObj.totalSeconds != null && _vastObj.totalSeconds != "")
			{
				_adTagVASTDuration = Number(_vastObj.adTagVASTDuration.totalSeconds);
			}

			if(_vastObj.adTagClickThrough != null && _vastObj.adTagClickThrough != "undefined")
			{
				_clickThruUrl = String(_vastObj.adTagClickThrough);
			}			
			
			if(_vastObj.adTagClickThroughNonLinear != null && _vastObj.adTagClickThroughNonLinear != "undefined")
			{
				_clickThruUrlNonLinear = String(_vastObj.adTagClickThroughNonLinear);
			}
			
			if(_vastObj.adParameters != null )
			{
				_adParameters = String(_vastObj.adParameters);
			}
			
			if(_vastObj.impressionArray != null )
			{
				//_impressionArray = _vastObj.impressionArray;
				if( _impressionArray == null )
				{
					_impressionArray = new Array();
				}
				for each(var impressionObj:Object in _vastObj.impressionArray)
				{
					var impressionURL:VASTUrl = new VASTUrl( impressionObj.url );
					_impressionArray.push( impressionURL );
				}
			}
			
			if(_vastObj.errorArray != null )
			{
				if( _errorArray == null )
				{
					_errorArray = new Array();
				}
				for each(var errorObj:Object in _vastObj.errorArray)
				{
					var errorURL:VASTUrl = new VASTUrl( errorObj.url );
					_errorArray.push( errorURL );
				}
				
			}
			
			if(_vastObj.extensionsArray != null )
			{
				if( _extensionsArray == null )
				{
					_extensionsArray = new Array();
				}
				for each(var extensionObj:Object in _vastObj.extensionsArray)
				{
					_extensionsArray.push( extensionObj );
				}
				
			}
			
			if(_vastObj.surveyArray != null )
			{
				if( _surveyArray == null )
				{
					_surveyArray = new Array();
				}
				for each(var surveyObj:Object in _vastObj.surveyArray)
				{
					var surveyURL:VASTUrl = new VASTUrl( surveyObj.url );
					_surveyArray.push( surveyURL );
				}
			}
			
			if(_vastObj.trackingArray != null )
			{
				_trackingArray = _vastObj.trackingArray;
			}				
			
			
			if(_vastObj.mediafileArray != null )
			{
				_mediafileArray = _vastObj.mediafileArray;
			}
			
			if(_vastObj.companionArray != null )
			{
				_companionArray = _vastObj.companionArray;
			}
			
			if(_vastObj.nonlinearArray != null )
			{
				_nonlinearArray = _vastObj.nonlinearArray;
			}				
						
			if(_vastObj.trkCreativeViewEvent != null )
			{
				_trkCreativeViewEvent = _vastObj.trkCreativeViewEvent;
			}
			
			if(_vastObj.trkStartEvent != null )
			{
				_trkStartEvent = _vastObj.trkStartEvent;
			}
			
			if(_vastObj.trkMidPointEvent != null )
			{
				_trkMidPointEvent = _vastObj.trkMidPointEvent;
			}
			
			if(_vastObj.trkFirstQuartileEvent != null )
			{
				_trkFirstQuartileEvent = _vastObj.trkFirstQuartileEvent;
			}
			
			if(_vastObj.trkThirdQuartileEvent != null )
			{
				_trkThirdQuartileEvent = _vastObj.trkThirdQuartileEvent;
			}
			
			if(_vastObj.trkCompleteEvent != null )
			{
				_trkCompleteEvent = _vastObj.trkCompleteEvent;
			}				
						
			if(_vastObj.trkMuteEvent != null )
			{
				_trkMuteEvent = _vastObj.trkMuteEvent;
			}
			
			if(_vastObj.trkUnmuteEvent != null ) 
			{
				_trkUnmuteEvent = _vastObj.trkUnmuteEvent; 
			}
			
			if(_vastObj.trkPauseEvent != null )
			{
				_trkPauseEvent = _vastObj.trkPauseEvent;
			}			
			
			if(_vastObj.trkFullScreenEvent != null )
			{
				_trkFullScreenEvent = _vastObj.trkFullScreenEvent;
			}
			
			if(_vastObj.clickTrackingArray != null )
			{
				//_trkClickThruEvent = _vastObj.clickTrackingArray;
				if( _trkClickThruEvent == null )
				{
					_trkClickThruEvent = new Array();
				}
				for each(var clickThruObj:Object in _vastObj.clickTrackingArray)
				{
					var clickThruURL:VASTUrl = new VASTUrl(clickThruObj.url);
					_trkClickThruEvent.push(clickThruURL);
				}
			}				
			if(_vastObj.trkCloseEvent != null )
			{
				_trkCloseEvent = _vastObj.trkCloseEvent;
			}
			
			if(_vastObj.trkRewindEvent != null )
			{
				_trkRewindEvent = _vastObj.trkRewindEvent;
			}				
			
			if(_vastObj.trkResumeEvent != null )
			{
				_trkResumeEvent = _vastObj.trkResumeEvent;
			}
			
			if(_vastObj.trkExpandEvent != null )
			{
				_trkExpandEvent = _vastObj.trkExpandEvent;
			}				
			
			if(_vastObj.trkCollapseEvent != null )
			{
				_trkCollapseEvent = _vastObj.trkCollapseEvent;
			}
			
			if(_vastObj.trkAcceptInvitationEvent != null )
			{
				_trkAcceptInvitationEvent = _vastObj.trkAcceptInvitationEvent;	
			}			
			
			if(_vastObj.trkCreativeViewEventNonLinear != null )
			{
				_trkCreativeViewEventNonLinear = _vastObj.trkCreativeViewEventNonLinear;
				
			}
			
			if(_vastObj.trkStartEventNonLinear != null )
			{
				_trkStartEventNonLinear = _vastObj.trkStartEventNonLinear;
			}			
			if(_vastObj.trkMidPointEventNonLinear != null )
			{
				_trkMidPointEventNonLinear = _vastObj.trkMidPointEventNonLinear;
			}
			
			if(_vastObj.trkFirstQuartileEventNonLinear != null )
			{
				_trkFirstQuartileEventNonLinear = _vastObj.trkFirstQuartileEventNonLinear;
			}			
			if(_vastObj.trkThirdQuartileEventNonLinear != null )
			{
				_trkThirdQuartileEventNonLinear = _vastObj.trkThirdQuartileEventNonLinear;
			}
			
			if(_vastObj.trkCompleteEventNonLinear != null )
			{
				_trkCompleteEventNonLinear = _vastObj.trkCompleteEventNonLinear;
			}			
			if(_vastObj.trkMuteEventNonLinear != null )
			{
				_trkMuteEventNonLinear = _vastObj.trkMuteEventNonLinear;
			}
			
			if(_vastObj.trkUnmuteEventNonLinear != null )
			{
				_trkUnmuteEventNonLinear = _vastObj.trkUnmuteEventNonLinear; 
			}			
			if(_vastObj.trkPauseEventNonLinear != null )
			{
				_trkPauseEventNonLinear = _vastObj.trkPauseEventNonLinear;
			}
			
			if(_vastObj.trkFullScreenEventNonLinear != null )
			{
				_trkFullScreenEventNonLinear = _vastObj.trkFullScreenEventNonLinear;
			}					
			if(_vastObj.clickTrackingArrayNonLinear != null )
			{
				//_trkClickThruEventNonLinear = _vastObj.clickTrackingArrayNonLinear;
				for each(var clickThruNonLinearObj:Object in _vastObj.clickTrackingArrayNonLinear)
				{
					var clickThruNonLinearURL:VASTUrl = new VASTUrl(clickThruNonLinearObj.url);
					_trkClickThruEventNonLinear.push(clickThruNonLinearURL);
				}
			}
			
			if(_vastObj.trkCloseEventNonLinear != null )
			{
				_trkCloseEventNonLinear = _vastObj.trkCloseEventNonLinear;
			}				
			
			if(_vastObj.trkRewindEventNonLinear != null )
			{
				_trkRewindEventNonLinear = _vastObj.trkRewindEventNonLinear;
			}
			if(_vastObj.trkResumeEventNonLinear != null )
			{
				_trkResumeEventNonLinear = _vastObj.trkResumeEventNonLinear;
			}			
			
			if(_vastObj.trkExpandEventNonLinear != null )
			{
				_trkExpandEventNonLinear = _vastObj.trkExpandEventNonLinear;
			}
			if(_vastObj.trkCollapseEventNonLinear != null )
			{
				_trkCollapseEventNonLinear = _vastObj.trkCollapseEventNonLinear;
			}			
						
			if(_vastObj.trkCollapseEventNonLinear != null )
			{
				_trkAcceptInvitationEventNonLinear = _vastObj.trkAcceptInvitationEventNonLinear;
			}	
			
			// collect all tracking events in one handy property
			this.collectTrackingEvents( PLACEMENT_LINEAR );
			this.collectTrackingEvents( PLACEMENT_NONLINEAR );
		}		
		
		//VAST Getters/Setters
		/**
		 * Returns a string indicating the ID of the current adPlacement (PLACEMENT_LINEAR/PLACEMENT_NONLINEAR)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adPlacement() : String
		{
			return _adPlacement;
		}
		/**
		 * sets the current adPlacement (PLACEMENT_LINEAR/PLACEMENT_NONLINEAR)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function set adPlacement(placement:String): void
		{
			if (placement != PLACEMENT_LINEAR && placement != PLACEMENT_NONLINEAR)
				_adPlacement = PLACEMENT_LINEAR;
			else
				_adPlacement = placement;
		}
		/**
		 * Returns a string indicating the ID of the current adTag
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adTagID() : String
		{
			return _adTagID;
		}
		/**
		 * Returns a string indicating adTagWrapperSystem of the XML file
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adTagWrapperSystem() : String
		{
			return _adTagWrapperSystem;
		}
		/**
		 * Returns a string indicating the VASTAdTagURL 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get VASTAdTagURL() : String
		{
			
			return _VASTAdTagURL;
		}
		/**
		 * Returns a string indicating the adTagSystem 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adTagSystem() : String
		{
			
				return _adTagSystem;

		}
		/**
		 * Returns a string indicating the adTagTitle 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adTagTitle() : String
		{
			
				return _adTagTitle;
		
		}
		/**
		 * Returns a string indicating the adTagImpressionURL 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get adTagImpressionURL() : String
		{
			//if (_adPlacement=PLACEMENT_LINEAR)
				return _adTagImpressionURL;
			//else
				//return _adTagImpressionURLNonLinear;
		}
		/**
		 * Returns a string containing parameters for a VPAID ad
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adParameters() : String
		{
			return _adParameters;
		}
		/**
		 * Returns an array of impression urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get impressionArray() : Array
		{
			//if (_adPlacement=PLACEMENT_LINEAR)
				return _impressionArray;
			//else
				//return _impressionArrayNonLinear;
		}

		/**
		 * Returns an array of error urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get errorArray() : Array
		{
			//if (_adPlacement=PLACEMENT_LINEAR)
				return _errorArray;
			//else
				//return _errorArrayNonLinear;
		}
		
		/**
		 * Returns an array of extensions
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get extensionsArray() : Array
		{
			//if (_adPlacement=PLACEMENT_LINEAR)
				return _extensionsArray;
			//else
				//return _errorArrayNonLinear;
		}
		
		/**
		 * Returns an array of survey urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get surveyArray() : Array
		{
			return _surveyArray;
		}

		/**
		 * Returns the duration of the media file
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get adTagVASTDuration() : Number
		{
			return _adTagVASTDuration;
		}
		/**
		 * Returns an array of media file urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get mediafileArray() : Array
		{
			return _mediafileArray;
		}
		/**
		 * Returns an array of urls for companion ads
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get companionArray() : Array
		{
			return _companionArray;
		}
		/**
		 * Returns an array of urls for nonlinear ads
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get nonlinearArray() : Array
		{
			return _nonlinearArray;
		}
		/**
		 * Returns an array of urls for the creative view trackers
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCreativeViewEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkCreativeViewEvent;
			else
				return _trkCreativeViewEventNonLinear;
		}
		
		/**
		 * Returns an array of urls for the click tracking trackers
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkClickThruEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkClickThruEvent;
			else
				return _trkClickThruEventNonLinear;
		}
		
				
		/**
		 * Returns an array of tracking urls for the start event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkStartEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkStartEvent;
			else
				return _trkStartEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the midpoint event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkMidPointEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkMidPointEvent;
			else
				return _trkMidPointEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the first quartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkFirstQuartileEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkFirstQuartileEvent;
			else
				return _trkFirstQuartileEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the third quartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkThirdQuartileEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkThirdQuartileEvent;
			else
				return _trkThirdQuartileEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the complete event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCompleteEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkCompleteEvent;
			else
				return _trkCompleteEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the mute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkMuteEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkMuteEvent;
			else
				return _trkMuteEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the unmute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkUnmuteEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkUnmuteEvent;
			else
				return _trkUnmuteEventNonLinear;
		}		
		/**
		 * Returns an array of tracking urls for the pause event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkPauseEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkPauseEvent;
			else
				return _trkPauseEventNonLinear;
		}

		/**
		 * Returns an array of tracking urls for the fullscreen event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkFullScreenEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkFullScreenEvent;
			else
				return _trkFullScreenEventNonLinear;
		}
		/**
		 * Returns clickThru url
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get clickThruUrl() : String
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _clickThruUrl;
			else
				return _clickThruUrlNonLinear;
		}		
		/**
		 * Returns an array of urls for close event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCloseEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkCloseEvent;
			else
				return _trkCloseEventNonLinear;
		}		/**
		/**
		 * Returns an array of urls for rewind event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkRewindEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkRewindEvent;
			else
				return _trkRewindEventNonLinear;
		}		/**
		 * Returns an array of urls for resume event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkResumeEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkResumeEvent;
			else
				return _trkResumeEventNonLinear;
		}		/**
		 * Returns an array of urls for the expand event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkExpandEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkExpandEvent;
			else
				return _trkExpandEventNonLinear;
		}		/**
		 * Returns an array of urls for the collapse event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCollapseEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkCollapseEvent;
			else
				return _trkCollapseEventNonLinear;
		}		/**
		 * Returns an array of urls for the accept invitation event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkAcceptInvitationEvent() : Array
		{
			if (_adPlacement==PLACEMENT_LINEAR)
				return _trkAcceptInvitationEvent;
			else
				return _trkAcceptInvitationEventNonLinear;
		}
		
		public function get vastParser(): VAST2Parser
		{
			return _vastObj;			
		}
		
		public function get vastVars(): Object
		{
			return _vastVars;			
		}
		
		protected function collectTrackingEvents( placement:String ) :void
		{
			this._adPlacement = placement;
			
			if( this.trackingEventsLinear == null )
			{
				this.trackingEventsLinear = new Array();
			}
			if( this.trackingEventsNonLinear == null )
			{
				this.trackingEventsNonLinear = new Array();
			}
			
			this.collectTrackingEvent( this.trkStartEvent, VASTTrackingEventType.START );
			this.collectTrackingEvent( this.trkMidPointEvent, VASTTrackingEventType.MIDPOINT );
			this.collectTrackingEvent( this.trkFirstQuartileEvent, VASTTrackingEventType.FIRST_QUARTILE );
			this.collectTrackingEvent( this.trkThirdQuartileEvent, VASTTrackingEventType.THIRD_QUARTILE );
			this.collectTrackingEvent( this.trkCompleteEvent, VASTTrackingEventType.COMPLETE );
			this.collectTrackingEvent( this.trkMuteEvent, VASTTrackingEventType.MUTE );
			this.collectTrackingEvent( this.trkCreativeViewEvent, VASTTrackingEventType.CREATIVE_VIEW );
			this.collectTrackingEvent( this.trkPauseEvent, VASTTrackingEventType.PAUSE );			
			this.collectTrackingEvent( this.trkReplayEvent, VASTTrackingEventType.REPLAY );
			this.collectTrackingEvent( this.trkFullScreenEvent, VASTTrackingEventType.FULLSCREEN );
			this.collectTrackingEvent( this.trkStopEvent, VASTTrackingEventType.STOP );
			this.collectTrackingEvent( this.trkUnmuteEvent, VASTTrackingEventType.UNMUTE );
			this.collectTrackingEvent( this.trkCloseEvent, VASTTrackingEventType.CLOSE );
			this.collectTrackingEvent( this.trkRewindEvent, VASTTrackingEventType.REWIND );
			this.collectTrackingEvent( this.trkResumeEvent, VASTTrackingEventType.RESUME );
			this.collectTrackingEvent( this.trkExpandEvent, VASTTrackingEventType.EXPAND );
			this.collectTrackingEvent( this.trkCollapseEvent, VASTTrackingEventType.COLLAPSE );
			this.collectTrackingEvent( this.trkAcceptInvitationEvent, VASTTrackingEventType.ACCEPT_INVITATION );
		}
		
		// collects an array of VASTUrls and adds it to trackingEvents
		protected function collectTrackingEvent( eventArray:Array, eventType:VASTTrackingEventType ) :void
		{
			if( eventArray != null && eventArray.length > 0 )
			{
				var event:VASTTrackingEvent = new VASTTrackingEvent( eventType );
				var urlArray:Array = new Array();

				for each( var trackingData:Object in eventArray )
				{
					var trackingUrl:VASTUrl = new VASTUrl( trackingData.url );
					urlArray.push( trackingUrl );
				}

				event.urls = urlArray;
				
				if( this._adPlacement == PLACEMENT_LINEAR )
				{
					this.trackingEventsLinear.push( event );
				}
				else
				{
					this.trackingEventsNonLinear.push( event );
				}
			}
		}
	}
}
