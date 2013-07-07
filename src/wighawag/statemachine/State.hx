/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.statemachine;
import msignal.Signal;
interface State<T> {

    /**
     * called when enterring into that state
    **/
    public function onEnter(model : T) : Void;

    /**
    *   Update the state
    *   dt : seconds passed since the last update
    **/
    public function update(dt : Float, model : T, event : Signal1<String>, elapsedTime : Float) : Void;


    /**
     * called when leaving that state
    **/
    public function onLeave(model : T) : Void;

}
