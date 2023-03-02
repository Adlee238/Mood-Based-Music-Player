//----------------------------------------------------------------------------
// name: wekinator-outputs.ck
// desc: demonstrates receiving Wekinator outputs over OSC
//       * listens for OSC message "/wek/output"
//       * prints out each message typetag and numArgs as it arrives
//       * NOTE: msg.numArgs() is the number of output dimension
//       * NOTE: this code can be modified to control synthesis
//----------------------------------------------------------------------------

// OSC Initialization
OscIn oin;
OscMsg msg;
12000 => oin.port;
oin.addAddress( "/mood/plain" );
oin.addAddress( "/mood/happy" );
oin.addAddress( "/mood/sad" );

// Mode Initialization
Math.random2(0, 2) => int MODE;
["chill vibes", "cheer energy", "sad day"] @=> string modes[];

// Music Library Initialization
// initialize playlists
["relax1.wav", "relax2.wav", "relax3.wav"] @=> string relaxPL[];
["peppy1.wav", "peppy2.wav", "peppy3.wav"] @=> string peppyPL[];
["sad1.wav", "sad2.wav", "sad3.wav"] @=> string sadPL[];
// combine into library
[relaxPL, peppyPL, sadPL] @=> string library[][];

// Sound Buffer Initialization
Math.random2(0, library[MODE].size()-1) => int songIdx;
me.dir() + "songs/" + library[MODE][songIdx] => string filename;
SndBuf buf => dac;
0.5 => buf.gain;
1 => buf.rate;
0 => buf.pos;
filename => buf.read;


// --------------------- MAIN FUNCTION --------------------------
// start listening for input
cherr <= "checking for user mood at port " <= oin.port()
      <= "..." <= IO.newline() <= IO.newline();
chout <= "Starting Mood: " <= modes[MODE] <= IO.newline();


// infinite event loop
while( true ) {
    oin => now;
    // detect mood gestures
    while( oin.recv(msg) )
    {   
        MODE => int prevMode;   // remember previous mode 
        if (msg.address == "/mood/plain") {
            0 => MODE;
        }
        else if (msg.address == "/mood/happy") {
            1 => MODE;
        }
        else if (msg.address == "/mood/sad") {
            2 => MODE;
        }
        
        // mood change occured: play new music of corresponding mode
        if (prevMode != MODE) {
            // acknowledge new music mode
            chout <= "Mood Change: " <= modes[MODE] <= IO.newline();
            Math.random2(0, library[MODE].size()-1) => songIdx;
            me.dir() + "songs/" + library[MODE][songIdx] => filename;
            
            // send new song to sound buf
            filename => buf.read;
            0 => buf.pos;
        }
    }
}