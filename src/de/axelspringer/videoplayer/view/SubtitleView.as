package de.axelspringer.videoplayer.view
{
		import de.axelspringer.videoplayer.model.vo.BildTvDefines;
		import de.axelspringer.videoplayer.model.vo.SrtData;
		import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
		import de.axelspringer.videoplayer.ui.SubtitleUI;
		import de.axelspringer.videoplayer.view.base.BaseView;
		
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.events.IOErrorEvent;
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		import flash.utils.Dictionary;
		import flash.utils.Timer;
         
        /** 
         * @author Jovica Aleksic
         */
          
        
        [Event(name="complete",type="flash.events.Event")]
        public class SubtitleView extends BaseView
        {        
                public var ui:SubtitleUI;             
                public var currentScale:Number = 1;  
                private var _text:String;
                private var originalSize:Object;
                private var timer:Timer;
                
             	private var srtDictionary:Dictionary = new Dictionary();
		        private var subtitlePosition:Number = 1;
		        private var subtitleSet:Boolean = false;
		       	private var activeSRTData:SrtData;
                  
                public function SubtitleView( stage:Sprite )
                {  
                	super( stage );
                      
                    this.ui = new SubtitleUI();
                    this.ui.mouseChildren = false;
                    this.ui.mouseEnabled = false;
                    this.ui.buttonMode = false;
                        
                    this.stage.addChild( this.ui );  
                } 
                
                public function init(subtitleUrl:String, skin:SkinBaseVO):void
                {       
					if(subtitleUrl == "") return;
					
					var srtLoader:URLLoader = new URLLoader();
					srtLoader.load(new URLRequest(subtitleUrl));
					srtLoader.addEventListener(Event.COMPLETE, onSrtLoaded);
					srtLoader.addEventListener(IOErrorEvent.IO_ERROR, onSrtError);
					this.ui.buildUi( skin );
					this.ui.x = 0;
					this.ui.setText("");
				}
		
				public function onSrtError(evt:IOErrorEvent = null):void
				{
					//this.player.ui.controls.dispatchEvent(new Event("disableSubtitle"));
				}
				
				public function onSrtLoaded(evt:Event):void
				{
					var srtString:String = (evt.currentTarget as URLLoader).data;
					var srtArray:Array = srtString.split("\r\n\r\n");
					
					for(var i:Number = 0; i< srtArray.length;i++)
					{
						var srtEntry:Array = (srtArray[i] as String).split("\r\n");//(0,(srtArray[i] as String).indexOf("\r\n"));
						var floatPattern:RegExp = /(,)/g;  
						srtEntry[1] = String(srtEntry[1]).replace(floatPattern,".");
						var timearray:Array = srtEntry[1].split(" --> ")
		 				
						var srtData:SrtData = new SrtData();
						srtData.starttime 	= this.stringToTime(timearray[0]);
						srtData.endtime		= this.stringToTime(timearray[1]);
						
						for(var j:Number = 2; j< srtEntry.length;j++)
						{
							srtData.text += srtEntry[j] + "\n";
						}	
						srtData.text = srtData.text.slice(0,srtData.text.length-1);
						
						this.srtDictionary[srtEntry[0]] = srtData;
					} 
				}
				
				private function stringToTime(stringTime:String):Number
				{
					var timePartArray:Array = stringTime.split(":");
					return Number(360 * Number(timePartArray[0]) + 60 * Number(timePartArray[1]) + parseFloat(timePartArray[2]));
				}
                
                public function updateSize():void
				{
					this.ui.y = BildTvDefines.height;
					this.ui.update();	
				}
				
				public function updateSrtPosition( time:Number ):void
				{
					for( var key:String in this.srtDictionary )
					{
						if( this.srtDictionary[key].endtime > time )
						{
							//trace(key + " endzeit akzeptiert: " + this.srtDictionary[key].endtime);
							this.subtitlePosition = Number(key);
							break;
						}
					}	
				}
				
                public function updateTime( time:Number ):void
				{
					this.activeSRTData = this.srtDictionary[String(this.subtitlePosition)];
					
					if( !this.activeSRTData ) return;
					
					//trace("check starttime: " + this.activeSRTData.starttime);
					if( this.activeSRTData.starttime <= time && time <= this.activeSRTData.endtime )
					{
						this.subtitleSet = true;	
					}
					else
					{
						if( this.subtitleSet ) this.subtitlePosition++;
						this.subtitleSet = false;
						//trace("at time " + time + " set Sub Pos up to:" + this.subtitlePosition);
					}
					
					if( this.subtitleSet )
					{
						this.updateText(this.activeSRTData.text);
					}
					else
					{
						this.updateText("");
					}
				}   
                
                public function updateText( text:String ):void
				{             
                  	this.ui.setText( text );
				}
        }
}