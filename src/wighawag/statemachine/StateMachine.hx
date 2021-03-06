/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.statemachine;
import msignal.Signal;
class StateMachine<T> {

    private var currentState : State<T>;

    private var transitions : Map<State<T>, Map<String,State<T>>>;

    //private var states : Map<Class<State<T>>, State<T>>;

    private var model : T;

    private var eventer : Signal1<String>;

    private var elapsedTime : Float;

    private var alreadyRun : Bool;

    private var states : Map<State<T>, Bool>;

    public function new(model : T) {
        states = new Map();
        this.model = model;
        eventer = new Signal1<String>();
        eventer.add(onEvent);
        elapsedTime = 0;
        alreadyRun = false;
    }

    // TODO make event enum , but extendable by user ?
//    public function addTransitionFromClass(prevState : Class<State<T>>, event : String, nextState : Class<State<T>>){
//        var pstate = states.get(prevState);
//        if (pstate == null){
//            pstate = new prevState;
//            states.set(prevState, pstate);
//        }
//
//        var nstate = states.get(nextState);
//        if (nstate == null){
//            nstate = new nextState;
//            states.set(nextState, nstate);
//        }
//
//        addTransition(pstate, event, nstate);
//    }

    // TODO make event enum , but extendable by user ?
    public function addTransition(prevState : State<T>, event : String, nextState : State<T>){
        if (transitions == null){
            currentState = prevState;
            transitions = new Map();
        }
        var hashSet = transitions.get(prevState);
        if (hashSet == null){
            hashSet = new Map<String,State<T>>();
        }
        hashSet.set(event,nextState);
        Report.anInfo("StateMachine", "add Transition ", prevState, event, nextState);
        transitions.set(prevState,hashSet);
        states.set(prevState, true);

        Report.anInfo("StateMachine", "-------------------");
        for(state in states.keys()){
            Report.anInfo("StateMachine", "            ------------");
            if(state == prevState){
                Report.anInfo("StateMachine", "-", state, "same as ", prevState);
                if(transitions.get(prevState) == null){
                    Report.anError("StateMachine", "-", "same but not saved", prevState);
                }else{
                    Report.anInfo("StateMachine", "-", "same and saved", prevState);
                }
            }
            if(transitions.get(state) == null){
                Report.anError("StateMachine", "transition not saved", state);
            }else{
                Report.anInfo("StateMachine", "transition saved", state);
            }
            if(transitions.get(prevState) == null){
                Report.anError("StateMachine", " same transition not saved", prevState);
            }else{
                Report.anInfo("StateMachine", " same transition saved", prevState);
            }
            Report.anInfo("StateMachine", "            ------- end -----");
        }
        Report.anInfo("StateMachine", "----------- end --------");

    }

//    public function setStartState(startingState : Class<State<T>>){
//        var state = states.get(startingState);
//        if (state == null){
//            throw "the starting state need to exist first";
//
//        }
//        currentState = state;
//    }

    /**
    *   Update the state machine and its current state
    *   dt : seconds passed since the last update
    **/
    public function update(dt : Float) : Void{
        if (!alreadyRun){   // for first state
            alreadyRun = true;
            currentState.onEnter(model);
        }
        elapsedTime += dt;
        currentState.update(dt, model, eventer, elapsedTime);
    }

    private function onEvent(value : String) : Void{
        var eventHash = transitions.get(currentState);
        if(eventHash == null){
            Report.anError("StateMachine", "no transition for state : ", currentState);
            return;
        }
        var nextState = eventHash.get(value);
        if (nextState == null){
            Report.anError("StateMachine", "no state transition for the duo: ", currentState, value);
            return;
        }
        currentState.onLeave(model);
        currentState = nextState;
        elapsedTime = 0;
        currentState.onEnter(model);
    }

}
