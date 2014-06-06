package de.axelspringer.videoplayer.util
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[Event(name="timer", type="flash.events.TimerEvent")]
	[Event(name="timerComplete", type="flash.events.TimerEvent")]
	
	public class PausableTimer extends EventDispatcher
	{
		protected var _timer:Timer;
		
		protected var _delay:Number;
		protected var _repeat:Number;
		
		protected var _thisTime:Number = 0;
		protected var _lastTime:Number;
		
		public function PausableTimer( delay:Number, repeat:int = 0 ) :void
		{
			_delay = delay;
			_repeat = repeat;
			
			_timer = new Timer( delay, repeat );
			_timer.addEventListener( TimerEvent.TIMER, onTimer );
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComplete );
		}
		
		public function start() :void
		{
			_lastTime = getTimer();
			_timer.start();
		}
		
		public function stop() :void
		{
			_timer.stop();
			_thisTime = 0;
		}
		
		public function reset() :void
		{
			_timer.reset();
			_thisTime = 0;
		}
		
		public function pause() :void
		{
			_timer.stop();
			_thisTime = getTimer() - _lastTime;
		}
		
		public function resume() :void
		{
			if( !_timer.running )
			{
				if( _thisTime > _timer.delay )
				{
					_thisTime = _timer.delay;
				}
				
				_timer.delay -= _thisTime;
				_thisTime = 0;
				this.start();
			}
		}
		
		protected function onTimer( event:TimerEvent ) :void
		{
			if( _timer.delay != _delay )
			{
				_timer.delay = _delay;
			}
			
			_lastTime = getTimer();
			
			this.dispatchEvent( event.clone() );
		}
		
		protected function onTimerComplete( event:TimerEvent ) :void
		{
			this.dispatchEvent( event.clone() );
		}
	}
}