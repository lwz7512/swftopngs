package com.ybcx.animdiy.common{
	
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	
	/**
	 * 该提示对象，只能放在一个不会被被动销毁和移除的容器中
	 * 也就是说，该对象，只能是主动触发show并自动消失来移除
	 * 不能被其所在容器在销毁子对象的同时来移除它<br/>
	 * 因此，本对象最好放在顶级的容器中，这样其他对象的移除不会影响到它
	 * 
	 * 2011/12/4
	 */ 
	public class Toast extends Sprite{
		
		private static var _instance:Toast;
		private static var _text:SimpleText;
		//FIXME, 为了能在弹出窗口时也能使用该组件，修改容器为舞台
		//2012/05/18
		private static var _parent:Stage;
		private static var _timer:Timer;
		
		private static const LONG_TIME:int = 6000;
		private static const SHORT_TIME:int = 2000;
		
		public function Toast(lokr:Locker){			
			//显示3秒不长不短
			_timer = new Timer(SHORT_TIME,1);
			//时间到了隐藏起来
			_timer.addEventListener(TimerEvent.TIMER, timeToElapse);
			//显示时画出背景
			this.addEventListener(Event.ADDED_TO_STAGE, drawBackground);
		}
		
		private function timeToElapse(evt:TimerEvent):void{
			//隐藏自己	
			if(_parent.contains(this))
				_parent.removeChild(this);
			_parent = null;
			
			//确保定时器停止
			_timer.stop();
		}
		
		private function drawBackground(evt:Event):void{
			//必须要清除绘制内容，否则会重叠显示
			this.graphics.clear();
			
			var toastWidth:Number = _text.width+12;
			var toastHeight:Number = _text.height+12;
			//边框清晰模式
			this.graphics.lineStyle(1, 0x666666, 1, true);
			this.graphics.beginFill(0x333333,0.8);
			this.graphics.drawRoundRect(-4, -4, toastWidth, toastHeight, 6, 6);
			this.graphics.endFill();
			
			//加个阴影
			var shadow:DropShadowFilter = new DropShadowFilter(4,45,0x666666,0.8);
			this.filters = [shadow];
		}

		
		public static function getInstance(context:Stage):Toast{
			if(!context) return null;//FIXME, 2013/03/18, Add null check...
			
			if(!_instance){
				_instance = new Toast(new Locker());				
			}
				
			_parent = context;
			
			if(_parent){
				return _instance;				
			}else{
				throw new Error("NO TOAST CONTAINER ASSIGNED! ");
				return null;
			}
		}
		
		/**
		 * 手动隐藏
		 * 
		 * 2013/04/07
		 */ 
		public function hide():void{
			TweenLite.to(this, 0.3, {alpha:0});
		}
		
		public function show(text:String, toastX:Number, toastY:Number, long:Boolean=false):void{			
			
			//创建文字
			if(!_text){
				//缓存起来
				_text = new SimpleText(text,0xFFFFFF,12,false,false);
				this.addChild(_text);				
			}else{
				//新的内容来了
				_text.text = text;
				//重绘背景
				drawBackground(null);
			}
						
			if(!_parent.contains(this))
				_parent.addChild(this);
			
			//居中显示
			this.x = toastX - _text.width/2;
			this.y = toastY;			
			
			if(long){//add time control... at 2013/03/12
				_timer.delay = LONG_TIME;				
			}else{
				_timer.delay = SHORT_TIME;
			}
			_timer.reset();//重置时间
			_timer.start();//开始显示计时
			
			TweenLite.killTweensOf(this);//FIXME, 2013/03/18
			
			//FIXME, 我擦，还得必须设定下初始的透明度
			//否则动画会有问题，第二次就不出来了
			//2011/11/23
			this.alpha = 0;			
			TweenLite.to(this, 0.6, {alpha:1});
		}
		
	} //end of class
}
class Locker{	}