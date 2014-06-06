package de.axelspringer.videoplayer.view
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.AdTimerTextVO;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.SkinVO;
	import de.axelspringer.videoplayer.ui.ControlsPanel;
	import de.axelspringer.videoplayer.ui.controls.VolumeControlVertical;
	import de.axelspringer.videoplayer.vast.VastDefines;
	import de.axelspringer.videoplayer.view.base.BaseView;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import tv.tvnext.stdlib.utils.StringUtils;
	
	public class ControlsView extends BaseView
	{
		public static const NAME:String = "ControlsView";
		
		protected var skin:SkinVO;
		public var controls:ControlsPanel;
		protected var duration:Number;
		protected var currentTime:Number;
		
		protected var shareStatus:Boolean;
		protected var fullscreenState:String;
		public var fadeOutTimer:Timer;
		
		private var adTexts:AdTimerTextVO;
		
		public function ControlsView( stage:Sprite )
		{
			super( stage );
			
			this.init();
		}
		
		protected function init() :void
		{
			this.controls = new ControlsPanel();
			this.stage.addChild( this.controls );
		
			this.controls.addEventListener( ControlEvent.PLAYPAUSE_CHANGE, forwardControlEvent );
			this.controls.addEventListener( ControlEvent.PROGRESS_CHANGE, forwardControlEvent );
			this.controls.addEventListener( ControlEvent.VOLUME_CHANGE, forwardControlEvent );
			this.controls.addEventListener( ControlEvent.BUTTON_CLICK, forwardControlEvent );
			this.controls.addEventListener( ControlEvent.BUTTON_OUT, forwardControlEvent );
			this.controls.addEventListener( ControlEvent.BUTTON_OVER, forwardControlEvent );
			
			this.y = BildTvDefines.height- BildTvDefines.HEIGHT_CONTROLS;
			
			this.fadeOutTimer = new Timer(2000,1);
			this.fadeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			this.fadeOutTimer.start();
			this.stage.parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			if(! BildTvDefines.isEmbedPlayer)
			{
				this.controls.visible = false;
			}
		}
		
		public function setSkin( skin:SkinVO, adText:AdTimerTextVO, sharingStatus:Boolean ) :void
		{
			this.skin = skin;
			this.adTexts = adText;
			this.shareStatus = sharingStatus;
			this.controls.setSkin( skin, adText );	
		}
		
		public function getSkin():SkinVO
		{
		 	return this.skin;
		}
		
		public function setDuration( time:Number ) :void
		{
			if( isNaN( time ) )
			{
				return;
			}
			
			this.duration = time;
			
			
			if( this.controls.btnBackgroundSmall ) this.controls.btnBackgroundSmall.visible = false;
			if( this.controls.btnBackgroundMiddle ) this.controls.btnBackgroundMiddle.visible = false;
			if( this.controls.btnBackgroundLarge ) this.controls.btnBackgroundLarge.visible = false;
						
			
			if( BildTvDefines.size == BildTvDefines.SIZE_MICRO && this.fullscreenState != "fullScreen" )
			{
				if( this.controls.timeDisplay )
				{
					this.controls.timeDisplay.txtTimeTotal.text = "";
					this.controls.timeDisplay.txtTimeVideo.visible = false;
					this.controls.timeDisplay.separatorMc.visible = false;
					this.controls.timeDisplay.slashMc.visible = false;
				}
				if((true == BildTvDefines.isBumper || true == this.controls.adControls.visible))
				{
					if( this.controls.shareBtn) this.controls.shareBtn.visible = false;		
					if( this.controls.hdBtn) this.controls.hdBtn.visible = false;		
					if( this.controls.subtitleBtn) this.controls.subtitleBtn.visible = false;		
					
				} 
				else
				{
					
					if( this.controls.shareBtn ) this.controls.shareBtn.visible = true;
					if( this.controls.hdBtn ) this.controls.hdBtn.visible = true;
					if( this.controls.subtitleBtn ) this.controls.subtitleBtn.visible = true;
					
				}
			}
			else
			{
				trace("live: "+ BildTvDefines.isLivePlayer + " bumper:"+ BildTvDefines.isBumper + "  time: " + time);
				if( time == -1 || BildTvDefines.isLivePlayer )
				{
					if(this.controls.timeDisplay)
					{
						this.controls.timeDisplay.txtTimeVideo.text = "LIVE";
						//this.controls.timeDisplay.txtTimeTotal.x = this.controls.btnPlayPause.width + 5;
						this.controls.timeDisplay.separatorMc.visible = false;
						this.controls.timeDisplay.slashMc.visible = false;
						this.controls.timeDisplay.txtTimeTotal.visible = false;
					}
					if( this.controls.timeDisplayDynamic )
					{
						this.controls.timeDisplayDynamic.visible = false;
						//this.controls.adControls //LIVE
					}
					
					if(this.controls.timeDisplay && true == BildTvDefines.isBumper)
					{
						this.controls.timeDisplay.txtTimeTotal.visible = true;
						this.controls.timeDisplay.txtTimeTotal.text = StringUtils.duration2hourminsec( time, false );
						
						if( true == this.controls.skin.styleTimeDisplay.rotation )
						{
							this.controls.timeDisplay.separatorMc.visible = false;
							this.controls.timeDisplay.slashMc.visible = true;
						}
						else
						{
							this.controls.timeDisplay.separatorMc.visible = true;
							this.controls.timeDisplay.slashMc.visible = false;
						}	
					}
						
					if((true == BildTvDefines.isBumper || true == this.controls.adControls.visible))
					{
						if( this.controls.hdBtn) this.controls.hdBtn.visible = false;		
						if( this.controls.subtitleBtn) this.controls.subtitleBtn.visible = false;
						
						
					} 
					else
					{
						
						if( this.controls.shareBtn ) this.controls.shareBtn.visible = true;
						if( this.controls.hdBtn ) this.controls.hdBtn.visible = true;
						if( this.controls.subtitleBtn ) this.controls.subtitleBtn.visible = true;
						
					}
					
					if(this.controls.shareBtn)
					{
						if( BildTvDefines.isLivePlayer )
						{
							//this.controls.shareBtn.visible = false;//
							if( this.controls.separator_2)  this.controls.separator_2.x = this.controls.fullscreenBtn.x - 7;
							this.controls.muteBtn.x = this.controls.fullscreenBtn.x - this.controls.volumeControl.width - 20;
							
							if( this.controls.volumeMinusBtn ) this.controls.volumeMinusBtn.x = this.controls.muteBtn.x + 10;
							if( this.controls.volumeControl ) this.controls.volumeControl.x = this.controls.muteBtn.x + this.controls.muteBtn.width + 15;
							if( this.controls.volumePlusBtn ) this.controls.volumePlusBtn.x = this.controls.volumeControl.x + this.controls.volumeControl.width;	
						}
					}	
				}
				else if( time == 0 )
				{
					//if( this.controls.separator_1 ) this.controls.separator_1.visible = false;
					//if( this.controls.separator_2 )this.controls.separator_2.visible = false;
					//if( this.controls.timeDisplay ) this.controls.timeDisplay.visible = false;
				}
				else
				{
					//this.controls.timeDisplay.separatorMc.visible = true;
					//this.controls.timeDisplay.slashMc.visible = true;
					
					if( this.controls.timeDisplay )
					{
						this.controls.timeDisplay.txtTimeTotal.visible = true;
						this.controls.timeDisplay.txtTimeTotal.text = StringUtils.duration2hourminsec( time, false );
						this.controls.timeDisplay.txtTimeVideo.visible = true;
						this.controls.timeDisplay.visible = !this.controls.adControls.visible;
					}
					if( this.controls.separator_1 ) this.controls.separator_1.visible = !this.controls.adControls.visible;
					if( this.controls.separator_2 ) this.controls.separator_2.visible = true;
					if( this.controls.shareBtn ) this.controls.shareBtn.visible = !this.controls.adControls.visible;
					if((true == BildTvDefines.isBumper || true == this.controls.adControls.visible))
					{
						if( this.controls.hdBtn) this.controls.hdBtn.visible = false;		
						if( this.controls.subtitleBtn) this.controls.subtitleBtn.visible = false;		
						
					} 
					else
					{
						
						if( this.controls.hdBtn ) this.controls.hdBtn.visible = true;
						if( this.controls.subtitleBtn ) this.controls.subtitleBtn.visible = true;
						 
					}
				}
				
				if(this.controls.shareBtn)
				{
					if( this.fullscreenState == "fullScreen" || BildTvDefines.isMoviePlayer  || ( false == this.controls.shareBtn.visible /*&& false == BildTvDefines.isWidgetPlayer*/ ) )
					{
						this.controls.shareBtn.visible = false;
					}
					else
					{
						this.controls.shareBtn.visible = true;
					}
				}
			} 
			
			
			this.controls.setBtnBackground();
			
			if( BildTvDefines.isLivePlayer )
			{
				if( this.controls.playPauseBtnBackground ) this.controls.playPauseBtnBackground.visible = false;
				if( this.controls.playPauseBtnBackgroundLive ) this.controls.playPauseBtnBackgroundLive.visible = true;			
			}
			else
			{
				if( this.controls.playPauseBtnBackground ) this.controls.playPauseBtnBackground.visible = true;
				if( this.controls.playPauseBtnBackgroundLive ) this.controls.playPauseBtnBackgroundLive.visible = false;		
			}
			
			if( true == this.controls.adControls.visible )
			{
				if( this.controls.btnBackgroundSmall ) this.controls.btnBackgroundSmall.visible =  this.controls.adControls.visible;
				if( this.controls.btnBackgroundMiddle ) this.controls.btnBackgroundMiddle.visible = false;
				if( this.controls.btnBackgroundLarge ) this.controls.btnBackgroundLarge.visible = false;
				
				if( this.controls.playPauseBtnBackground ) this.controls.playPauseBtnBackground.visible = false;
				if( this.controls.playPauseBtnBackgroundLive ) this.controls.playPauseBtnBackgroundLive.visible = false;		
			}
			else if( this.fullscreenState == "fullScreen" )
			{
				if( this.controls.visibleButtons <= 3 )
				{
					if( this.controls.btnBackgroundSmall ) this.controls.btnBackgroundSmall.visible = !this.controls.adControls.visible;
				}
				else if( this.controls.visibleButtons == 4 )
				{
					if( this.controls.btnBackgroundMiddle ) this.controls.btnBackgroundMiddle.visible = !this.controls.adControls.visible;
				}
			}
			else
			{
				if( this.controls.visibleButtons <= 2 )
				{
					if( this.controls.btnBackgroundSmall ) this.controls.btnBackgroundSmall.visible = !this.controls.adControls.visible;
				}
				else if( this.controls.visibleButtons == 3 || ( BildTvDefines.isBumper &&  this.controls.visibleButtons ))
				{
					if( this.controls.btnBackgroundMiddle ) this.controls.btnBackgroundMiddle.visible = !this.controls.adControls.visible;
					//trace("ads:" + this.controls.adControls.visible + "    bg:" + this.controls.btnBackgroundMiddle.visible);
				}
				else if( this.controls.visibleButtons == 4 )
				{
					if( this.controls.btnBackgroundLarge ) this.controls.btnBackgroundLarge.visible = !this.controls.adControls.visible;
				}
			}
			
			var hdBtnVisible:Boolean = false;
			var shareBtnVisible:Boolean = false;
			var subtitleBtnVisible:Boolean = false;
			
			if(this.controls.hdBtn) hdBtnVisible = this.controls.hdBtn.visible;
			if(this.controls.shareBtn) shareBtnVisible = this.controls.shareBtn.visible;
			if(this.controls.subtitleBtn) subtitleBtnVisible = this.controls.subtitleBtn.visible;
			ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/controls/setup/buttons", {'id': BildTvDefines.playerId, 'hq': hdBtnVisible, 'like': shareBtnVisible, 'subtitle': subtitleBtnVisible});
			
			if(!hdBtnVisible)
			{
				trace("");
			}
			
			this.controls.resize(fullscreenState);
		}

		public function updateTime( time:Number, total:Number = 0 ) :void
		{
			if( this.controls.adControls.visibility )
			{
				var duration:Number = 0;
				if( isNaN( this.duration ) || this.duration <= 0 )
				{
					duration = -1;					
				}
				else
				{
					duration = this.duration - time;
				}
				if( this.controls.adControls.lastAdTime > Math.floor( duration ) && duration >= 0 )
				{
//					ExternalInterface.call("function(){if (window.console) console.log('FLASH TRACK: PROGRESS AD-->"+duration+"');}");
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/comercial/timeupdate", {'id': BildTvDefines.playerId, 'duration': Math.floor( duration )});			
				}
				
				this.controls.adControls.setRemainingTime( duration );
			}
			else
			{
				this.currentTime = time;
				
				if( (null != this.controls.timeDisplay) && this.controls.timeDisplay.txtTimeVideo.visible )
				{				
					this.controls.setTime( time );
				} 
				if( null != this.controls.timeDisplayDynamic )
				{
					this.controls.setTime( time );
				}			
			}		
		}
		
		public function updatePlayProgress( progress:Number ) :void
		{
			if( this.controls.progressBar ) this.controls.progressBar.playProgress = progress;
			if( this.controls.timeDisplayDynamic ) this.controls.timeDisplayDynamic.x = Math.ceil( (this.controls.progressBar.x + this.controls.progressbarMaskSprite.width * progress)) ;
		}
		
		public function updateLoadProgress( progress:Number ) :void
		{
			this.controls.progressBar.loadProgress = progress;
		}
		
		public function setPlayingStatus( playing:Boolean ) :void
		{
			this.controls.playPauseBtn.phase = playing ? 1 : 0;
		}
		
		public function setVolume( volume:Number ) :void
		{
			if( this.controls.volumeControl != null )
			{
				if( this.controls.volumeControlMode == VolumeControlVertical.NAME )
				{
					VolumeControlVertical(this.controls.volumeControl).paneMask.scaleY = -volume * 6.5;
				}	
				else
				{
					trace(this + " Set Vol: " + volume);
					this.controls.volumeControl.volume = volume;
				}
			}
		}
		
		public function enable( enable:Boolean ) :void
		{
			this.controls.mouseEnabled = enable;
			this.controls.mouseChildren = enable;
		}
		
		public function enableSeeking( enable:Boolean ) :void
		{
			this.controls.progressBar.enableSeeking( enable );
		}
		
		public function showAdControls( show:Boolean, adType:String = "" ):void		
		{
			trace( this + " showAdControls: " + show + ":::::" + adType + "     zeit:" + this.duration );
			
			if(adType != VastDefines.ADTYPE_OVERLAY)
			{
				if( show )
				{
					var adText:String;
					
					//Check MicroPlayer Size and set the ad text for the MicroPLayer
					if( BildTvDefines.size == BildTvDefines.SIZE_MICRO )
					{
						adText = this.adTexts.adTimerMicroplayerText;
					}
					else
					{
						//check the duration of the ad and set the unknow Duration text 
						//if the duration is invalid
						if( isNaN( duration ) && duration < 0 )
						{
							adText = this.adTexts.adTimerUnknownTimeText;
						}
						else
						{
							//check adtype and set the prposed adText
							//if the adType is not set, set the unknownTime Text as Default
							if( adType == VastDefines.ADTYPE_PREROLL )
							{
								adText = this.adTexts.adTimerPrerollText;
							}
							else if( adType == VastDefines.ADTYPE_POSTROLL )
							{
								adText = this.adTexts.adTimerPostrollText;
							}
							else
							{
								adText = this.adTexts.adTimerUnknownTimeText;
							}
						}
					}
					trace( this + " Params for Ad Text :: duration  = " + duration + " :: adType = " + adType + " :: adText = " + adText );
					
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/comercial/enable", {'id': BildTvDefines.playerId, 'duration': this.duration, 'adtype':adType, 'adText':adText});				
				}
				else
				{
					ExternalInterface.call("com.xoz.videoplayer.instances." + BildTvDefines.playerId + ".events.publish","video/comercial/disable", {'id': BildTvDefines.playerId});				
				}
			}
			
			if( adType == VastDefines.ADTYPE_NONE ) return;
			
			if( this.controls.adControls ) this.controls.adControls.visibility = show;
			if( BildTvDefines.isEmbedPlayer)
			{
				if( this.controls.adControls ) this.controls.adControls.visible = show;
				if( this.controls.separator_1 )this.controls.separator_1.visible = !show;
				if( this.controls.playPauseBtn )this.controls.playPauseBtn.visible = !show;
				if( this.controls.playPauseBtnBackground )this.controls.playPauseBtnBackground.visible = !show;
				if( this.controls.playPauseBtnBackgroundLive )this.controls.playPauseBtnBackgroundLive.visible = !show;
				if( this.controls.timeDisplay ) this.controls.timeDisplay.visible = !show;
				if( this.controls.subtitleBtn ) this.controls.subtitleBtn.visible = !show;
				if( this.controls.hdBtn ) this.controls.hdBtn.visible = !show;
				if( this.controls.shareBtn ) this.controls.shareBtn.visible = !show;
				if( this.controls.bilddeBtn ) this.controls.bilddeBtn.visible = !show;
				if( this.controls.bilddeBtnTooltip ) this.controls.bilddeBtnTooltip.visible = false;
				if( BildTvDefines.isWidgetPlayer || this.skin.styleAdText.display == "none" )
				{
					if( this.controls.progressBar )this.controls.progressBar.visible = !show;	
				}			
				if( this.controls.adControls )this.controls.adControls.setAdType( adType );
				//if( this.controls.background && BildTvDefines.isWidgetPlayer ) this.controls.background.visible = !show;
				if( this.controls.timeDisplayDynamic && BildTvDefines.isWidgetPlayer ) this.controls.timeDisplayDynamic.visible = false;
				
				if( show )
				{				
					// reset in case the ad fails to give new values
					this.updateTime( 0 );
					this.updatePlayProgress( 0 );
					this.setDuration( 0 );
				}
				
				this.resizeControls( this.fullscreenState );
			}
		}
		
		public function showJingleControls( show:Boolean ) :void
		{
			if(! BildTvDefines.isEmbedPlayer)
			{
				this.controls.jingleControls.visible = show;
			}
		}
	
		public function resizeControls(fullscreenState:String) :void
		{			
			this.fullscreenState = fullscreenState;
			if( fullscreenState == "fullScreen" )
			{
				//this.showMailButton( false );
				//this.showShareButton( false );
				//this.showPopupButton( false );
				this.fadeOutTimer.start();
			}
			else
			{
				//this.fadeOutTimer.stop();
				//this.controls.visible = true;
			}
			/* else if( ! this.controls.mcAdControls.visible )
			{ 					
				this.showMailButton( this.mailStatus );
				//this.showShareButton( this.shareStatus );
				this.showPopupButton( this.popupStatus );
				this.fadeOutTimer.stop();
			} */
			
			// show or hide timedisplay by calling setDuration() again
			this.setDuration( this.duration );
			// update the current time by calling updateTime() again
			this.updateTime( this.currentTime );
			
			this.controls.resize(fullscreenState);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{	
			if( BildTvDefines.isEmbedPlayer)
			{
				this.controls.visible = true;
			}
			
			
			if( this.fullscreenState == "fullScreen" || BildTvDefines.isWidgetPlayer )
			{ 				
				this.fadeOutTimer.stop();
				this.fadeOutTimer.start();
			}
			
			Mouse.show();
		}
		
		private function onTimerComplete(evt:Event):void
		{		
			if( this.fullscreenState == "fullScreen" || BildTvDefines.isWidgetPlayer )
			{ 
				this.controls.visible = false;
			}
			
			if( !BildTvDefines.isWidgetPlayer && !BildTvDefines.isEmbedPlayer )//this.fullscreenState == "fullScreen")
			{
				Mouse.hide();
			}
			
			this.fadeOutTimer.stop();
		}
		
		protected function forwardControlEvent( e:ControlEvent ) :void
		{
			this.dispatchEvent( new ControlEvent( e.type, e.data, e.bubbles, e.cancelable ) );
		}
	}
}