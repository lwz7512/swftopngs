package{	
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	
	public class BaseApp extends Sprite{
		
		//FIXME, 舞台状态的检测开关
		//2012/11/20
		protected var stageAvailable:Boolean;
		
		public function BaseApp(){
//			trace(">>>this is base app...");
			//舞台准备好后创建应用
			this.addEventListener(Event.ADDED_TO_STAGE, buildApp);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroyApp);
		}
		
		/**
		 * 初始化系统参数，构建系统界面，并监听导航事件
		 * TO BE OVERRIDED BY SUBCLASS...
		 */ 
		protected function buildApp(event:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, buildApp);
			setupStage();					
			
			//如果舞台大小为0
			if(!stage.stageWidth) {
				trace("Stage is unavailable, stop to build app!");				
			}else{
				stageAvailable = true;
				safeBuild();
			}
			
		}
		
		/**
		 * 舞台已经获得，而且有大小，子类用于构建内容；
		 * 
		 * 2012/11/20
		 */ 
		protected function safeBuild():void{
			
		}
		
		private function setupStage():void{
			//不允许图形缩放
			this.stage.scaleMode =StageScaleMode.NO_SCALE;
			//从左上角开始绘制
			this.stage.align = StageAlign.TOP_LEFT;
			//隐藏所有默认右键菜单
			this.stage.showDefaultContextMenu = false;
			
		}
		
		protected function destroyApp(evt:Event):void{
			trace("app destroyed!");
		}
		
	} //end of class
}