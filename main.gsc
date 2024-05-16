

//All MP files are supported, if something doesnt work, let us know!
#include common_scripts\utility;
#include common_scripts\_destructible;
#include maps\mp\gametypes\_damagefeedback;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

//Preprocessor Global Chaining
#define WELCOME_MSG = BASE_MSG + GREEN + PROJECT_TITLE;

//Preprocessor Globals
#define GREEN = "";
#define BASE_MSG = "EnCoReV16 Loaded - ^2cabconmodding.com";
#define PROJECT_TITLE = "";

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
    level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
        if(isDefined(self.playerSpawned))
            continue;
        self.playerSpawned = true;
        if( !isDefined(self.stopThreading) )
        {
            self func_menuInit();
            self.stopThreading = true;
        }
    }
}


func_menuInit()
{
    self setup_defineVars();
    self thread setup_welcomeMessage();
    if( self isHost() && !isDefined(self.threaded) )
    {
        self.playerSetting["hasMenu"] = true;
        self.playerSetting["verfication"] = "host";
        self iPrintLn("Your Status changed to ^2"+self.playerSetting["verfication"]);
        self thread menuBase();
        self.threaded = true;
        self iPrintLn("Press ^2[{+speed_throw}]^7 and ^2[{+melee}]");
    }
    else
    {
        self.playerSetting["verfication"] = "unverified";
        self.playerSetting["hasMenu"] = true;
        self thread menuBase();
        self.threaded = true;
    }
    self runMenuIndex();
}


setup_welcomemessage()
{
    //self thread hud_message::oldNotifyMessage( "^2Welcome to Project "+getMenuName(), "Created by CabCon", "headicon_dead", (0,0,1), "mp_challenge_complete", 15 );
}


setup_defineVars()
{
    if(!isDefined(self.menu))
        self.menu = [];
    if(!isDefined(self.gamevars))
        self.gamevars = [];
    if(!isDefined(self.playerSetting))
        self.playerSetting = [];
        
    //self.menu
    self.menu["currentMenu"] = "";
    self.menu["isLocked"] = false;
    self.menu["message_type"] = ::Sb;
    
    //self.playerSetting
    self.playerSetting["verfication"] = "unverified";
    self.playerSetting["isInMenu"] = false;
    
    //self.gamevars

    
    setDvar("sv_cheats", true);
    self setup_initMenuSettings();
}

menuBase()
{
    while(true)
    {
        if(!(self getLocked()))
        {
            if(!(self getUserIn()))
            {
                if( self adsButtonPressed() && self meleeButtonPressed() )
                {
                    self iPrintLn("Check Updates on ^2cabconmodding.com^7!");
                    self controlMenu("open", "main");
                    self menuBase_playSound("uin_main_bootup");
                    wait 0.2;
                }
            }
            else
            {
                if( self adsButtonPressed() || self attackButtonPressed() && !self getLocked() )
                {
                    self menuBase_playSound( "mouse_over" );
                    self.menu["curs"][getCurrent()] += self attackButtonPressed();
                    self.menu["curs"][getCurrent()] -= self adsButtonPressed();
 
                    if( self.menu["curs"][getCurrent()] > self.menu["items"][self getCurrent()].name.size-1 )
                        self.menu["curs"][getCurrent()] = 0;
                    if( self.menu["curs"][getCurrent()] < 0 )
                        self.menu["curs"][getCurrent()] = self.menu["items"][self getCurrent()].name.size-1;
                    self thread scrollMenu();
                    wait .15;
                }
 
                if( self useButtonPressed() && !self getLocked())
                {
                    if(self.menu["items"][self getCurrent()].func[self getCursor()] == ::headline)
                    {
                        L("headline");
                    }
                    else
                    {
                        self menuBase_playSound("uin_main_enter");
                        self.menu["ui"]["scroller"] scaleOverTime(.1, 105, 10);
                        if(isDefined(self.menu["items"][self getCurrent()].input4[self getCursor()]))
                        {
                            self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                            self.menu["items"][self getCurrent()].input1[self getCursor()],
                            self.menu["items"][self getCurrent()].input2[self getCursor()],
                            self.menu["items"][self getCurrent()].input3[self getCursor()],
                            self.menu["items"][self getCurrent()].input4[self getCursor()]
                        );
                        }
                        else if(isDefined(self.menu["items"][self getCurrent()].input3[self getCursor()]))
                        {
                            self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                            self.menu["items"][self getCurrent()].input1[self getCursor()],
                            self.menu["items"][self getCurrent()].input2[self getCursor()],
                            self.menu["items"][self getCurrent()].input3[self getCursor()]
                        );
                        }
                        else if(isDefined(self.menu["items"][self getCurrent()].input2[self getCursor()]))
                        {
                            self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                            self.menu["items"][self getCurrent()].input1[self getCursor()],
                            self.menu["items"][self getCurrent()].input2[self getCursor()]
                        );
                        }
                        else if(isDefined(self.menu["items"][self getCurrent()].input1[self getCursor()]))
                        {
                            self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                            self.menu["items"][self getCurrent()].input1[self getCursor()]
                        );
                        }
                        else
                            self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] ();
                        wait 0.1;
                        self.menu["ui"]["scroller"] scaleOverTime(.1, 210, 20);
                        wait 0.1;
                    }
                }
 
                if( self meleeButtonPressed() && !self getLocked())
                {
                    self menuBase_playSound("uin_main_pause");
                    if( isDefined(self.menu["items"][self getCurrent()].parent) )
                    {
                        self controlMenu("newMenu", self.menu["items"][self getCurrent()].parent);
                    }
                    else
                    {
                        self controlMenu("close");
                    }
                    wait 0.1;
                }
            }
        }
        wait .05;
    }
}
 
scrollMenu()
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-8]) || self.menu["items"][self getCurrent()].name.size <= 11)
    {
        for(m = 0; m < 11; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[m]);
        self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
 
       for( a = 0; a < 11; a ++ )
        {
            if( a != self getCursor() )
                self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
        }
        self.menu["ui"]["text"][self getCursor()] affectElement("alpha", 0.18, 1);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            optNum = 0;
            for(m = self getCursor()-8; m < self getCursor()+3; m++)
            {
                if(!isDefined(self.menu["items"][self getCurrent()].name[m]))
                    self.menu["ui"]["text"][optNum] setText("");
                else
                    self.menu["ui"]["text"][optNum] setText(self.menu["items"][self getCurrent()].name[m]);
                optNum++;
            }
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][8].y )
                self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][8].y);
            if( self.menu["ui"]["text"][8].alpha != 1 )
            {
                for( a = 0; a < 11; a ++ )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
                self.menu["ui"]["text"][8] affectElement("alpha", 0.18, 1);    
            }
        }
        else
        {
            for(m = 0; m < 11; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[self.menu["items"][self getCurrent()].name.size+(m-11)]);
            self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+11)].y);
            for( a = 0; a < 11; a ++ )
            {
                if( a != ((self getCursor()-self.menu["items"][self getCurrent()].name.size)+11) )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
            }
            self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+11)] affectElement("alpha", 0.18, 1);
        }
    }
}
scrollMenuText()
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-8]) || self.menu["items"][self getCurrent()].name.size <= 11)
    {
        for(m = 0; m < 11; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[m]);
        self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            optNum = 0;
            for(m = self getCursor()-8; m < self getCursor()+3; m++)
            {
                if(!isDefined(self.menu["items"][self getCurrent()].name[m]))
                    self.menu["ui"]["text"][optNum] setText("");
                else
                    self.menu["ui"]["text"][optNum] setText(self.menu["items"][self getCurrent()].name[m]);
                optNum++;
            }
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][8].y )
                self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][8].y);
        }
        else
        {
            for(m = 0; m < 11; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[self.menu["items"][self getCurrent()].name.size+(m-11)]);
            self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+11)].y);
        }
    }
}



controlMenu( type, par1 )
{
    if( type == "open" || type == "open_withoutanimation")
    {
        self.menu["ui"]["background"] = self createRectangle("CENTER", "CENTER", getMenuSetting("pos_x"), 0, 210, 0, getMenuSetting("color_background"), 1, 0, getMenuSetting("shader_background"));
        self.menu["ui"]["scroller"] = self createRectangle("CENTER", "CENTER", getMenuSetting("pos_x"), -145, 0, 20, getMenuSetting("color_scroller"), 2, 0, getMenuSetting("shader_scroller"));
        self.menu["ui"]["barTop"] = self createRectangle("CENTER", "CENTER", getMenuSetting("pos_x"), -180, 0, 50, getMenuSetting("color_barTop"), 3, 0, getMenuSetting("shader_barTop"));
        
        if(!self._var_menu["animations"] || type == "open_withoutanimation")
        {
            self.menu["ui"]["background"] affectElement("alpha", 0.00001, getMenuSetting("alpha_background"));
            self.menu["ui"]["background"] scaleOverTime(.00001, 210, 500);
            self.menu["ui"]["scroller"] scaleOverTime(.00001, 210, 500);
            self.menu["ui"]["scroller"] affectElement("alpha", 0.00001, getMenuSetting("alpha_scroller"));
            self.menu["ui"]["scroller"] scaleOverTime(.00001, 210, 20);
            self.menu["ui"]["barTop"] affectElement("alpha", 0.00001, getMenuSetting("alpha_barTop"));
            self.menu["ui"]["barTop"] scaleOverTime(.00001, 210, 50);
            if( !self getUserIn() )
                self buildTextOptions(par1);
        }
        else
        {
            self.menu["ui"]["background"] affectElement("alpha", 0.2, getMenuSetting("alpha_background"));
            self.menu["ui"]["background"] scaleOverTime(.3, 210, 500);
            self.menu["ui"]["scroller"] scaleOverTime(.1, 210, 500);
            self.menu["ui"]["scroller"] affectElement("alpha", 0.2, getMenuSetting("alpha_scroller"));
            self.menu["ui"]["scroller"] scaleOverTime(.4, 210, 20);
            self.menu["ui"]["barTop"] affectElement("alpha", 0.1, getMenuSetting("alpha_barTop"));
            self.menu["ui"]["barTop"] scaleOverTime(.2, 210, 50);
            self buildTextOptions(par1);
            wait .2;
        }
        
        self.playerSetting["isInMenu"] = true;
    }
    if( type == "close" )
    {
        self.menu["isLocked"] = true;
        self controlMenu("close_animation");
        self.menu["ui"]["background"] affectElement("alpha", 0.2, 0.1);
        self.menu["ui"]["scroller"] affectElement("alpha", 0.2, 0.1);
        self.menu["ui"]["barTop"] affectElement("alpha", 0.2, 0.1);
        wait .2;
        self.menu["ui"]["background"] destroy();
        self.menu["ui"]["scroller"] destroy();
        self.menu["ui"]["barTop"] destroy();
        self.menu["isLocked"] = false;
        self.playerSetting["isInMenu"] = false;
    }
    if( type == "newMenu")
    {
        if(!self.menu["items"][par1].name.size <= 0)
            {
                self.menu["isLocked"] = true;
                self controlMenu("close_animation");
                self buildTextOptions(par1);
                L("^1 This Menu include :" + tostring(self.menu["items"][self getCurrent()].name.size) + " Options");
                self.menu["isLocked"] = false;
            }
        else
                self iPrintLn("^1On the Current Map ("+getMapName()+") "+getOptionName()+" can not use !");
    }
    if( type == "lock" )
    {
        self controlMenu("close");
        self.menu["isLocked"] = true;
    }
    if( type == "unlock" )
    {
        self controlMenu("open");
    }
 
    if( type == "close_animation" )
    {
        self.menu["ui"]["title"] affectElement("alpha", 0.05, 0);
        for( a = 11; a >= 0; a-- )
        {
            self.menu["ui"]["text"][a] affectElement("alpha", 0.05, 0); 
        }
        for( a = 11; a >= 0; a-- )
            self.menu["ui"]["text"][a] destroy();
        self.menu["ui"]["title"] destroy();
    }
}
 
buildTextOptions(menu)
{
    self.menu["currentMenu"] = menu;
    if(!isDefined(self.menu["curs"][getCurrent()]))
            self.menu["curs"][getCurrent()] = 0;
    self.menu["ui"]["title"] = self createText(getMenuSetting("font_title"),1.5, 5, self.menu["items"][menu].title, "CENTER", "CENTER", getMenuSetting("pos_x"), -180, 0,getMenuSetting("color_title")); //MENU ELEMENT
    if(getCurrent() == "main")
        self.menu["ui"]["title"] affectElement("alpha", 0.2, 1);
    else
        self.menu["ui"]["title"] affectElement("alpha", 0.05, 1);
    self thread scrollMenuText();
    for( a = 0; a < 11; a ++ )
    {
        self.menu["ui"]["text"][a] = self createText(getMenuSetting("font_options"),1.2, 5, self.menu["items"][menu].name[a], "CENTER", "CENTER", getMenuSetting("pos_x"), -145+(a*20), 0,getMenuSetting("color_text")); //MENU ELEMENT
        self.menu["ui"]["text"][a] affectElement("alpha", 0, 0.3);
    }
    self.menu["ui"]["text"][0] affectElement("alpha", 0.2, 1);
    self thread scrollMenu();
    self thread scrollMenu();
}

addMenu(menu, title, parent)
{
    if( !isDefined(self.menu["items"][menu]) )
    {
        self.menu["items"][menu] = spawnstruct();
        self.menu["items"][menu].name = [];
        self.menu["items"][menu].func = [];
        self.menu["items"][menu].input1 = [];
        self.menu["items"][menu].input2 = [];
        self.menu["items"][menu].input3 = [];
        self.menu["items"][menu].input4 = [];
        
        self.menu["items"][menu].title = title;
 
        if( isDefined( parent ) )
            self.menu["items"][menu].parent = parent;
        else
            self.menu["items"][menu].parent = undefined;
    }
}
 
addMenuPar_withDef(menu, name, func, input1, input2, input3, input4)
{
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input2) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input3) )
        self.menu["items"][menu].input3[count] = input3;
    if( isDefined(input4) )
        self.menu["items"][menu].input4[count] = input4;
}

addHeadline(menu,name)
{
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = "--- "+name+" ---";
    self.menu["items"][menu].func[count] = ::headline;
}

/* SYSTEM UTILITES */
S(i)
{
    self IPrintLn(i);
}
Sb(i)
{
    self IPrintLnBold(i);
}

L(i)
{
    if(self.menu_setting["developer"])
        self IPrintLn("Console ^1"+i);
}
C(i)
{
    self SayAll(i);
}
getCurrent()
{
    return self.menu["currentMenu"];
}
 
getLocked()
{
    return self.menu["isLocked"];
}
 
getUserIn()
{
    return self.playerSetting["isInMenu"];
}
 
getCursor()
{
    return self.menu["curs"][getCurrent()];
}

getOptionName()
{
    return self.menu["items"][self getCurrent()].name[self getCursor()];
}
getMenuName()
{
    return "EnCoReV" + getVersion() + " MW3 Multiplayer";
}

getVersion()
{
    return "16";
}


//mover getter and setter 

getMapName()
{
    return level.script;
}
getNameNotClan(player)
{
    return player.name;
}
affectElement(type, time, value)
{
    // if( type == "x" || type == "y" )
    //     self moveOverTime(time);
    // else
    //     self fadeOverTime(time);
 
    if( type == "x" )
        self.x = value;
    if( type == "y" )
        self.y = value;
    if( type == "alpha" )
        self.alpha = value;
    if( type == "color" )
        self.color = value;
}

/*

    Menu system design

*/

setup_initMenuSettings()
{
    if(!isDefined(self.menu_setting))
        self.menu_setting = [];
    
    //VALUES DEFAULT
    self.menu_setting["pos_x"] = 200;
    
    self.menu_setting["shader_background"] = "white";
    self.menu_setting["shader_scroller"] = "white";
    self.menu_setting["shader_barTop"] = "white";
    
    self.menu_setting["color_title"] = (1, 1, 1);
    self.menu_setting["color_text"] = (1, 1, 1);
    
    self.menu_setting["color_background"] = (0, 0, 0);
    self.menu_setting["color_scroller"] = (0, 0.5, 1);
    self.menu_setting["color_barTop"] = (0, 0.5, 1);
    
    self.menu_setting["alpha_background"] = 0.5;
    self.menu_setting["alpha_scroller"] = 0.5;
    self.menu_setting["alpha_barTop"] = 0.8;
    
    self.menu_setting["font_title"] = "default";
    self.menu_setting["font_options"] = "default";
    
    
    self.menu_setting["animations"] = true;
    self.menu_setting["sounds"] = true;
    self.menu_setting["developer"] = false;
    
    //Special Values
    self.menu_setting["sound_in_menu"] = true;
    

    L("Loaded");
}
switchDesignTemplates(name)
{
   /* switch(name)
    {
        case "default":
            self menuEventSetMultiParameter(200,"
","white","white",(1, 1, 1),(1, 1, 1),(0, 0, 0),(.8, 0, 0),(.8, 0, 0),0.5,0.5,0.8,"default","default",true,false);
            updateMenuSettings();
            self iPrintLn("Desing set to ^2"+getOptionName());
        break;
        case "saved_1":
            self menuEventSetMultiParameter(200,"gradient","ui_slider2","ui_slider2",(1, 1, 1),(1, 1, 1),(0, 0, 0),(1, 0, 0),(1, 0, 0),0.7,1,1,"small","small",true,false);
            updateMenuSettings();
            self iPrintLn("Desing set to ^2"+getOptionName());
        break;
        case "saved_2":
            self menuEventSetMultiParameter(0,"zom_icon_bonfire","scorebar_zom_long_1","scorebar_zom_long_2",(1, 1, 1),(1, 1, 1),(0, 0, 0),(0.8, 0, 0),(0.8, 0, 0),0.7,0.8,0.8,"objective","objective",false,false);
            updateMenuSettings();
            self iPrintLn("Desing set to ^2"+getOptionName());
        break;
        case "random":
            array_caller = GetArrayKeys(level.shader);
            array_caller_fonts = GetArrayKeys(level.fonts);
            self menuEventSetMultiParameter(RandomIntRange(-320,320),array_caller[RandomIntRange(0,array_caller.size)],array_caller[RandomIntRange(0,array_caller.size)],array_caller[RandomIntRange(0,array_caller.size)],(randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255),(randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255),(randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255),(randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255),(randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255,randomintrange( 0, 255 )/255),randomfloatrange( 0, 1 ),randomfloatrange( 0, 1 ),randomfloatrange( 0, 1 ),array_caller_fonts[RandomIntRange(0,array_caller_fonts.size)],array_caller_fonts[RandomIntRange(0,array_caller_fonts.size)],true,false);
            updateMenuSettings();
            self iPrintLn("Desing set to ^2"+getOptionName());
        break;
        default:
        self iPrintLn("^1Your Design is not defined!");
        break;
    }*/
}

menuEventSetMultiParameter(pos_x,shader_background,shader_scroller,shader_barTop,color_title,color_text,color_background,color_scroller,color_barTop,alpha_background,alpha_scroller,alpha_barTop,font_title,font_options,animations,developer)
{
    self.menu_setting["pos_x"] = pos_x;
    
    self.menu_setting["shader_background"] = shader_background;
    self.menu_setting["shader_scroller"] = shader_scroller;
    self.menu_setting["shader_barTop"] = shader_barTop;
    
    self.menu_setting["color_title"] = color_title;
    self.menu_setting["color_text"] = color_text;
    
    self.menu_setting["color_background"] = color_background;
    self.menu_setting["color_scroller"] = color_scroller;
    self.menu_setting["color_barTop"] = color_barTop;
    
    self.menu_setting["alpha_background"] = alpha_background;
    self.menu_setting["alpha_scroller"] = alpha_scroller;
    self.menu_setting["alpha_barTop"] = alpha_barTop;
    
    self.menu_setting["font_title"] = font_title;
    self.menu_setting["font_options"] = font_options;
    
    
    self.menu_setting["animations"] = animations;
    self.menu_setting["sounds"] = true;
    self.menu_setting["developer"] = developer;
}
givePar_Theme()
{
    self iPrintLn("^2Theme Dump");
    self iPrintLn(getMenuSetting("pos_x")+" - "+getMenuSetting("shader_background")+" - "+getMenuSetting("shader_scroller")+" - "+getMenuSetting("shader_barTop")+" - "+getMenuSetting("color_title")+" - "+getMenuSetting("color_text")+" - "+getMenuSetting("color_background")+" - "+getMenuSetting("color_scroller")+" - "+getMenuSetting("color_barTop")+" - "+getMenuSetting("alpha_background")+" - "+getMenuSetting("alpha_scroller")+" - "+getMenuSetting("alpha_barTop")+" - "+getMenuSetting("font_title")+" - "+getMenuSetting("font_options")+" - "+getMenuSetting("animations")+" - "+getMenuSetting("developer"));
    self iPrintLn("Dumped in the Log. (check console for more informations)");
}

menuBase_playSound(sound)
{
    if(self.menu_setting["sounds"])
    {
        // self PlaySound(sound);
        L("menuBase_playSound ->" + sound);
    }
}

setTogglerFunction(i)
{
    self.menu_setting[i] = !self.menu_setting[i];
    self iPrintLn(i+" set to ^2"+ self.menu_setting[i]);
}

getMenuSetting(i)
{
    if(!isDefined(self.menu_setting[i]))
        return undefined;
    else
        return self.menu_setting[i];
}

setMenuSetting(i,value)
{
    if(IsSubStr(i, "pos"))
    {
        self.menu_setting[i] = getMenuSetting(i) + value;
        self iPrintLn("X Position ^2"+getMenuSetting(i));
    }
    else if(IsSubStr(i, "color"))
    {
        self.menu_setting[i] = value;
    }
    else if(IsSubStr(i, "alpha"))
    {
        self.menu_setting[i] = value;
    }
    else if(IsSubStr(i, "shader"))
    {
        self.menu_setting[i] = value;
    }
    else if(IsSubStr(i, "font"))
    {
        self.menu_setting[i] = value;
    }
    else
    {
        self iPrintLn("^1This Value is not defined in any type!");
        self.menu_setting[i] = value;
    }
    self iPrintLn(i+" set to ^2"+value);
    updateMenuSettings();
}

updateMenuSettings()
{
    self.menu["isLocked"] = true;
    self.menu["ui"]["background"] destroy();
    self.menu["ui"]["scroller"] destroy();
    self.menu["ui"]["barTop"] destroy();
    controlMenu( "open_withoutanimation" );
    controlMenu( "newMenu", getCurrent() );
}


///------------------------------
///Extras
///------------------------------
headline()
{
    
}
setMenuSetting_ThemeColor(i)
{
    setMenuSetting("color_scroller",i);
    setMenuSetting("color_barTop",i);
}
setMenuSetting_color_scroller(i)
{
    setMenuSetting("color_scroller",i);
}
setMenuSetting_color_barTop(i)
{
    setMenuSetting("color_barTop",i);
}
setMenuSetting_TopTextColor(i)
{
    setMenuSetting("color_title",i);
}
setMenuSetting_TextColor(i)
{
    setMenuSetting("color_text",i);
}
setMenuSetting_BackgroundColor(i)
{
    setMenuSetting("color_background",i);
}
getMenuSetting_Time()
{
    return 0.1;
}

setMenuBackground(i)
{
    setMenuSetting("shader_background",i);
}
setMenuScroller(i)
{
    setMenuSetting("shader_scroller",i);
}
setMenuBarTop(i)
{
    setMenuSetting("shader_barTop",i);
}

runMenuIndex( menu )
{
    self addmenu("main", getMenuName());
    self addMenuPar_withDef("main", "Client Main Modifications", ::controlMenu, "newMenu", "main_mods");
    self addMenuPar_withDef("main", "Fun Mods", ::controlMenu, "newMenu", "main_fun");
    self addMenuPar_withDef("main", "Perk Menu", ::controlMenu, "newMenu", "main_perks");
    self addMenuPar_withDef("main", "Message Menu", ::controlMenu, "newMenu", "main_messages");
    self addMenuPar_withDef("main", "Weapons Menu", ::controlMenu, "newMenu", "main_weapons");
    self addMenuPar_withDef("main", "Weapons Mods Menu", ::controlMenu, "newMenu", "main_weapons_mods");
    self addMenuPar_withDef("main", "Bullets Menu", ::controlMenu, "newMenu", "main_bullets");
    self addMenuPar_withDef("main", "Aimbot Menu", ::controlMenu, "newMenu", "main_aimbot");
    self addMenuPar_withDef("main", "Entity Menu", ::controlMenu, "newMenu", "main_entity");
    self addMenuPar_withDef("main", "Visions Menu", ::controlMenu, "newMenu", "main_vis");
    self addMenuPar_withDef("main", "SFX Menu", ::controlMenu, "newMenu", "main_sfx");
    self addMenuPar_withDef("main", "Graphics Effects Menu", ::controlMenu, "newMenu", "main_effects");
    self addMenuPar_withDef("main", "Location Menu", ::controlMenu, "newMenu", "main_location");
    self addMenuPar_withDef("main", "Bots Menu", ::controlMenu, "newMenu", "main_bots");
    self addMenuPar_withDef("main", "Host Menu", ::controlMenu, "newMenu", "main_host");
    self addMenuPar_withDef("main", "Lobby Menu", ::controlMenu, "newMenu", "main_lobby");
    self addMenuPar_withDef("main", "Clients", ::controlMenu, "newMenu", "main_clients");
    self addMenuPar_withDef("main", "Hitmarker", ::controlMenu, "newMenu", "main_hitmaker");
    self addMenuPar_withDef("main", "Customize Menu", ::controlMenu, "newMenu", "main_customize");

    self addmenu("main_weapons", "Weapons Menu", "main");
    for ( i = 0; i < level.weaponlist.size; i++ ) {
        self addMenuPar_withDef("main_weapons", level.weaponlist[i], ::func_giveWeapon, level.weaponlist[i]);  
    }

    self addmenu("main_weapons_mods", "Weapons Mods Menu", "main");
    self addMenuPar_withDef("main_weapons_mods", "Print Current Weapon",::func_printCurrentWeapon);
    
    
    self addmenu("main_vis", "Visions Menu", "main");
    self.visions_array = ["jeepride","jeepride_cobra","jeepride_flyaway","jeepride_tunnel","jeepride_zak","mpintro","mpnuke","mpnuke_aftermath","mpoutro","black_bw","cargoship","cargoship_blast","cargoship_indoor","cargoship_indoor2","cheat_bw","cheat_bw_contrast","cheat_bw_invert","cheat_bw_invert_contrast","cheat_chaplinnight","cheat_contrast","cheat_invert","cheat_invert_contrast","cliffhanger","co_break","co_overgrown","cobra_down","cobra_sunset1","cobra_sunset2","cobra_sunset3","cobrapilot","contingency","contingency_thermal_inverted","coup","coup_hit","coup_sunblind","dcemp","dcemp_emp","dcemp_iss","dcemp_iss_death","dcemp_office","dcemp_parking","dcemp_parking_lightning","dcemp_postemp","dcemp_postemp2","dcemp_tunnels","default","default_night","default_night_mp","end_game","end_game2"];
    for ( i = 0; i < self.visions_array.size; i++ ) {
        self addMenuPar_withDef("main_vis", self.visions_array[i], ::func_SetVision, self.visions_array[i]);  
    }
    
    self addmenu("main_mods", "Client Main Modifications", "main");
    self addMenuPar_withDef("main_mods", "Toggle God Mode", ::func_godmode);
    //self addMenuPar_withDef("main_mods", "Toggle Quick Field Of View", ::quick_modificator, "cg_fov_default",90,120,65);
    //self addMenuPar_withDef("main_mods", "3rd Person Range Bar", ::quick_modificator, "cg_thirdpersonrange",300,1000,120);
    //self addMenuPar_withDef("main_mods", "Toggle Aquatic Screen", ::quick_modificator, "r_waterSheetingFX_enable", 1, 0);
    self addMenuPar_withDef("main_mods","Toggle Left Side Weapon", ::quick_modificator,"cg_gun_y",10,0);
    //self addMenuPar_withDef("main_mods", "Pixel Graphic", ::quick_modificator, "r_graphicContentBlur", 1, 0);
    //self addMenuPar_withDef("main_mods", "Black Screen", ::quick_modificator, "r_makeDark_enable", 1, 0);
    //self addMenuPar_withDef("main_mods", "Poison FX", ::quick_modificator, "r_poisonFX_debug_enable", 1, 0);
    //self addMenuPar_withDef("main_mods", "Aquatic Screen", ::quick_modificator, "r_waterSheetingFX_enable", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Disable FXs", ::quick_modificator, "fx_enable", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle Fog Effect", ::quick_modificator, "r_fog", 0, 1);
    //self addMenuPar_withDef("main_mods", "Toggle Water Sheeting Effect", ::quick_modificator, "r_waterSheetingFX_enable", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Render Distance", ::quick_modificator, "r_zfar", 1, 500,0);
    //self addMenuPar_withDef("main_mods", "Toggle DoF", ::quick_modificator, "r_dof_enable", 0, 1);
    //self addMenuPar_withDef("main_mods", "Toggle DoF Bias", ::quick_modificator, "r_dof_bias", 0, 3, 0.5);
    //self addMenuPar_withDef("main_mods", "Toggle Override DoF", ::quick_modificator, "r_dof_tweak", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Crosshair", ::quick_modificator, "cg_drawCrosshair", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle Crosshair Enemy Effect", ::quick_modificator, "cg_crosshairEnemyColor", 0, 1);
    /*self addMenuPar_withDef("main_mods", "Toggle Display DoF Informations", ::quick_modificator, "r_dof_showdebug", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Super Speed", ::quick_modificator,"g_speed",500,999,190);
    self addMenuPar_withDef("main_mods", "Toggle Super Gravity", ::quick_modificator, "bg_gravity", 400,100,800);
    self addMenuPar_withDef("main_mods", "Toggle Super Physical Gravity", ::quick_modificator, "phys_gravity", 50,0,-800);
    self addMenuPar_withDef("main_mods", "Toggle Timescale", ::quick_modificator, "timescale", 2,.5,1);
    self addMenuPar_withDef("main_mods", "Disable Wallrun", ::quick_modificator, "wallrun_enabled", 0, 1);
    self addMenuPar_withDef("main_mods", "Disable Black Ops 3 Exo Suit", ::quick_modificator, "doublejump_enabled", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle Disable Ai Spawners", ::quick_modificator, "ai_disableSpawn", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Friendlyfire", ::quick_modificator, "scr_friendlyfire", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle Entity Collision", ::quick_modificator, "phys_entityCollision", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle Show Map", ::quick_modificator, "ui_showmap", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle ui_hud_showobjicons", ::quick_modificator, "ui_hud_showobjicons", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle ui_hud_obituaries", ::quick_modificator, "ui_hud_obituaries", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle ui_hud_hardcore", ::quick_modificator, "ui_hud_hardcore", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle ui_debugMode", ::quick_modificator, "ui_debugMode", 1, 0);*/
    self addMenuPar_withDef("main_mods", "Toggle r_zfar", ::quick_modificator, "r_zfar", 1, 0);
    /*self addMenuPar_withDef("main_mods", "Toggle r_vsync", ::quick_modificator, "r_vsync", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle r_viewModelPrimaryLightTweakSpecularStrength", ::r_viewModelPrimaryLightTweakSpecularStrength, "r_vsync", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle r_viewModelPrimaryLightTweakDiffuseStrength", ::quick_modificator, "r_viewModelPrimaryLightTweakDiffuseStrength", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle r_sunsprite_size", ::quick_modificator, "r_sunsprite_size", 0, 100);
    self addMenuPar_withDef("main_mods", "Toggle r_sunglare_max_lighten", ::quick_modificator, "r_sunglare_max_lighten", 0, 1, 5);
    self addMenuPar_withDef("main_mods", "Toggle r_sunglare_fadeout", ::quick_modificator, "r_sunglare_fadeout", 0, 1, 5);
    self addMenuPar_withDef("main_mods", "Toggle r_sunglare_fadein", ::quick_modificator, "r_sunglare_fadein", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle r_sunflare_fadeout", ::quick_modificator, "r_sunflare_fadeout", 0, 1);
    self addMenuPar_withDef("main_mods", "Toggle r_thermalDetailScale", ::quick_modificator, "r_thermalDetailScale", 0, 1);
self addMenuPar_withDef("main_mods", "Toggle ui_version_show", ::quick_modificator, "ui_version_show", 1, 0);*/
    self addMenuPar_withDef("main_mods", "Toggle r_scaleViewport", ::quick_modificator, "r_scaleViewport", 0, 1);
    //self addMenuPar_withDef("main_mods", "Toggle r_heroLighting", ::quick_modificator, "r_heroLighting", 0, 1);
    //self addMenuPar_withDef("main_mods", "Toggle r_fullbright", ::quick_modificator, "r_fullbright", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle r_brightness", ::quick_modificator, "r_brightness", 1, 0);
    //self addMenuPar_withDef("main_mods", "Toggle r_blacklevel", ::quick_modificator, "r_blacklevel", 1, 0);
    self addMenuPar_withDef("main_mods", "Toggle r_blur", ::quick_modificator, "r_blur", 1, 0);
    //self addMenuPar_withDef("main_mods", "Toggle fx_freeze", ::quick_modificator, "fx_freeze", 1, 0);   
    //self addMenuPar_withDef("main_mods", "Toggle ui_scorelimit", ::quick_modificator, "ui_scorelimit", 10, 1000);
    self addMenuPar_withDef("main_mods", "Test quickModifyDvar", ::quickModifyDvar, "g_speed", 300, "saved");
    self addMenuPar_withDef("main_mods", "Test quickModifyDvar", ::quickModifyDvar, "cg_fov", 26, "saved");
    self addMenuPar_withDef("main_mods", "Test quickModifyDvar", ::quickModifyDvar, "cg_fov", 26, "saved");
    self addMenuPar_withDef("main_mods", "Test quickModifyDvar", ::quickModifyDvar, "cg_fov", 26, "saved");
    self addMenuPar_withDef("main_mods", "Test func_SetViewModel viewhands_sas", ::func_SetViewModel, "viewhands_sas");
    self addMenuPar_withDef("main_mods", "Test func_SetViewModel viewhands_delta", ::func_SetViewModel, "viewhands_delta");
    self addMenuPar_withDef("main_mods", "Test func_SetViewModel viewhands_yuri_europe", ::func_SetViewModel, "viewhands_yuri_europe");
    self addMenuPar_withDef("main_mods", "Test func_SetViewModel", ::func_SetViewModel, "viewhands_juggernaut_ally");
    self addMenuPar_withDef("main_mods", "Test func_ufomode", ::func_ufomode);
    self addMenuPar_withDef("main_mods", "Test hitmarkerMain", ::hitmarkerMain);
    
    
    
    self addmenu("main_customize", "Customize Menu", "main");
    self addMenuPar_withDef("main_customize", "Theme Color", ::controlMenu, "newMenu", "main_customize_theme");
    self addMenuPar_withDef("main_customize", "Menu Postion", ::controlMenu, "newMenu", "main_customize_x");
    self addMenuPar_withDef("main_customize", "Toggle Menu Sound", ::setTogglerFunction,"sounds");
    self addMenuPar_withDef("main_customize", "Toggle Developer", ::setTogglerFunction,"developer");
    
    self addHeadline("main_customize","Menu Information");
    self addMenuPar_withDef("main_customize", "Current Version", ::S, "This is version ^2"+getVersion());
    self addMenuPar_withDef("main_customize", "Updates?", ::S, "Check out ^2cabconmodding.com^7 for updates!");
    
    
    self addmenu("main_hitmaker", "Hitmarker", "main");
    self addMenuPar_withDef("main_hitmaker", "Toggle Hitmarker", ::func_hitmarker);
    self addMenuPar_withDef("main_hitmaker", "hitBodyArmor", ::hitMarkerSimulateHit, "hitBodyArmor");
    self addMenuPar_withDef("main_hitmaker", "hitLightArmor", ::hitMarkerSimulateHit, "hitLightArmor");
    self addMenuPar_withDef("main_hitmaker", "hitJuggernaut", ::hitMarkerSimulateHit, "hitJuggernaut");
    self addMenuPar_withDef("main_hitmaker", "scavenger", ::hitMarkerSimulateHit, "scavenger");
    self addMenuPar_withDef("main_hitmaker", "default", ::hitMarkerSimulateHit, "");
    self addMenuPar_withDef("main_hitmaker", "Hitmarker Color", ::controlMenu, "newMenu", "main_hitmaker_color");
    //self addMenuPar_withDef("main_hitmaker", "Toggle Crazy Hitmarker", ::func_hitmarker_flashing_pos);
    //self addMenuPar_withDef("main_hitmaker", "Crazy Hitmarker Settings", ::controlMenu, "newMenu", "main_hitmaker");

    self addmenu("main_hitmaker_color", "Hitmarker Color", "main_hitmaker");
    self updateMenu_color_system_Map("main_hitmaker_color", ::func_hitmarker_color);
    
    /*
    self CreateMenu("main_hitmaker_crazy_settings","Settings","main_hitmaker");
    self addToggle("main_hitmaker_crazy_settings","Toggle Crazy Hitmarker",::func_hitmarker_flashing_pos,self.var["hitmarker_pos_flash"]);
    self addToggle("main_hitmaker_crazy_settings","Position Animaitions",::func_hitmarker_pos_flash_animated,self.var["hitmarker_pos_flash_animated"]);
    self addValueOption("main_hitmaker_crazy_settings","Area Size",::func_hitmarker_distance,self.var["hitmarker_pos_flash_distance"],100,0,1,.00001);
    self addValueOption("main_hitmaker_crazy_settings","Position Speed",::func_hitmarker_speed,self.var["hitmarker_pos_flash_speed"],3,.001,.001,.00001);
    self addOption("main_hitmaker_crazy_settings","^1Reset Crazy Hitmarker",::func_hitmarker_reset,false);
    self addOption("main_hitmaker","^1Reset Hitmarker",::func_hitmarker_reset,true);
*/

    
    
    
    
    
    
    
    
    
    
    self addmenu("main_customize_x", "Postion X of Menu", "main_customize");
    self addMenuPar_withDef("main_customize_x", "X to ^2+100 ^7Position", ::setMenuSetting, "pos_x",100);
    self addMenuPar_withDef("main_customize_x", "X to ^2+10 ^7Position", ::setMenuSetting, "pos_x",10);
    self addMenuPar_withDef("main_customize_x", "X to ^2+1 ^7Position", ::setMenuSetting, "pos_x",1);
    self addMenuPar_withDef("main_customize_x", "X to ^1-1 ^7Position", ::setMenuSetting, "pos_x", (0-1));
    self addMenuPar_withDef("main_customize_x", "X to ^1-10 ^7Position", ::setMenuSetting, "pos_x", (0-10));
    self addMenuPar_withDef("main_customize_x", "X to ^1-100 ^7Position", ::setMenuSetting, "pos_x", (0-100));
    
    self addmenu("main_customize_theme", "Theme Color", "main_customize");
    self updateMenu_color_system_Map("main_customize_theme", ::setMenuSetting_ThemeColor);
    
    self addmenu("main_bots", "Theme Color", "main");
    self addMenuPar_withDef("main_bots", "Spawn Bot", ::func_SpawnBot);
 
    
    self addmenu("main_clients", "Client List", "main");
    self setup_clientMenu();
}

updateMenu_color_system_Map(menu,i)
{
    self addMenuPar_withDef(menu, "Set To Royal Blue", i, ((34/255),(64/255),(139/255)));
    self addMenuPar_withDef(menu, "Set To Raspberry", i, ((135/255),(38/255),(87/255)));
    self addMenuPar_withDef(menu, "Set To Skyblue", i, ((135/255),(206/255),(250/250)));
    self addMenuPar_withDef(menu, "Set To Hot Pink", i, ((1),(0.0784313725490196),(0.5764705882352941)));
    self addMenuPar_withDef(menu, "Set To Lime Green", i, (0,1,0));
    self addMenuPar_withDef(menu, "Set To Dark Green", i, (0/255, 51/255, 0/255));
    self addMenuPar_withDef(menu, "Set To Brown", i, ((0.5450980392156863),(0.2705882352941176),(0.0745098039215686)));
    self addMenuPar_withDef(menu, "Set To Blue", i, (0,0,1));
    self addMenuPar_withDef(menu, "Set To Red", i, (1,0,0));
    self addMenuPar_withDef(menu, "Set To Maroon Red", i, (128/255,0,0));
    self addMenuPar_withDef(menu, "Set To Orange", i, (1,0.5,0));
    self addMenuPar_withDef(menu, "Set To Purple", i, ((0.6274509803921569),(0.1254901960784314),(0.9411764705882353)));
    self addMenuPar_withDef(menu, "Set To Cyan", i, (0,1,1));
    self addMenuPar_withDef(menu, "Set To Yellow", i, (1,1,0));
    self addMenuPar_withDef(menu, "Set To Black", i, (0,0,0));
    self addMenuPar_withDef(menu, "Set To White", i, (1,1,1));
}


refreshClienMenu()
{
    //NOT VALID
}
setup_clientMenu()
{
    if(self isHost())
    {
        for( a = 0; a < getplayers().size; a++ )
        {
            player = getplayers()[a];
            self addMenuPar_withDef("main_clients", toString(getNameNotClan(player))+" Options", ::controlMenu, "newMenu", "main_clients_"+getNameNotClan(player));
            self addmenu("main_clients_"+toString(getNameNotClan(player), getNameNotClan( player ))+" Options", "main_clients");
            
        }
    }
    else
        self addMenuPar_withDef("main_clients", "You can not access this Menu!", ::controlMenu, "newMenu", "main_clients");
}


verificationOptions( player, par2, par3)
{
    if ( player IsTestClient() )
    {
        self iPrintLn("^1You can not modify the Bots");
        return;
    }
    if( par2 == "changeVerification" )
    {
        if( player == getplayers()[0] )
             return self iPrintLn( "^1You can not modify the Host");
        player setVerification(par3);
        self iPrintLn(getNameNotClan( player )+"'s verification has been changed to "+par3);
        player iPrintLn("Your verification has been changed to "+par3);
        player iPrintLn("Press ^2[{+speed_throw}]^7 and ^2[{+melee}]");
    }
}

setVerification( type )
{
    self.playerSetting["verfication"] = type;
    self iPrintLn("Your Status changed to ^2"+self.playerSetting["verfication"]);
}

getVerfication()
{
    if( self.playerSetting["verfication"] == "admin" )
        return 3;
    if( self.playerSetting["verfication"] == "co-host" )
        return 2;
    if( self.playerSetting["verfication"] == "verified" )
        return 1;
    if( self.playerSetting["verfication"] == "unverified" )
        return 0;
}


isEmpty(i)
{
    if(i == "" || !isDefined(i))
        return true;
    else
        return false;
}
    
    
func_godmode()
{
    if(!isDefined(self.gamevars["godmode"]))
    {
        self.gamevars["godmode"] = true;
        self enableInvulnerability(); 
        self iPrintLn("God Mode ^2ON");
    }
    else
    {
        self.gamevars["godmode"] = undefined;
        self disableInvulnerability(); 
        self iPrintLn("God Mode ^1OFF");
    }
}


/* BASIC FUNCTIONS */

//INCLUDE: #include common_scripts\_destructible;

func_ufomode()
{
    if(!isDefined(self.gamevars["ufomode"]) || self.gamevars["ufomode"] == false)
    {
        self thread func_activeUfo();
        self.gamevars["ufomode"] = true;
        self iPrintLn("Press [{+frag}] To Fly");
    }
    else
    {   
        self notify("func_ufomode_stop");
        self unlink();
        self.gamevars["ufomode"] = false;
    }
    self iPrintLn("UFO Mode " + self.gamevars["ufomode"] ? "^2ON" : "^1OFF");
}
func_activeUfo()
{
    self endon("func_ufomode_stop");
    UFO = spawn("script_model", self.origin);
    for(;;)
    {
        if(self FragButtonPressed())
        {
            self playerLinkTo(UFO);
            // UFO moveTo(self.origin+vector_scal(anglesToForward(self getPlayerAngles()),20),.01);
        }
        else
        {
            self unlink();
        }
        wait .001;
    }
}



quick_modificator(input,i_1,i_2,i_3)
{
    
    if(isEmpty(i_3))
        i_3 = undefined;
    if(self.gamevars[input]==0 || !isDefined(self.gamevars[input]))
    {
        SetDvar( input , i_1 ); 
        self.gamevars[input]=1;
        self iPrintLn(getOptionName()+" ^2ON^7 - var "+input+" set to "+i_1);
    }
    else if(self.gamevars[input]==1)
    {
        SetDvar( input, i_2 ); 
        if(isDefined(i_3))
        {
            self.gamevars[input]=2;
            self iPrintLn(getOptionName()+" ^2ON^7 - var "+input+" set to "+i_2);
        }
        else
        {
            self.gamevars[input]=0;
            self iPrintLn(getOptionName()+" ^1OFF^7 - var "+input+" set to "+i_2);
        }
    }
    else if(self.gamevars[input]==2)
    {
        SetDvar( input,i_3 ); 
        self.gamevars[input]=0;
        self iPrintLn(getOptionName()+" ^1OFF^7 - var "+input+" set to "+i_3);
    }
    
}


quickModifyDvar(dvar, modify, type, datatype) {
    self iPrintLn(dvar + " was ^1" + datatype == "int" ? GetDvarInt(dvar) : datatype == "float" ? GetDvarFloat(dvar) : datatype == "vector" ? GetDvarVector(dvar): getDvar(dvar));
    if(type == "saved") {
        SetSavedDvar(dvar, modify);
    } else {
        SetDvar(dvar, modify);
    }
    self iPrintLn(dvar + " set to ^2" + datatype == "int" ? GetDvarInt(dvar) : datatype == "float" ? GetDvarFloat(dvar) : datatype == "vector" ? GetDvarVector(dvar): getDvar(dvar));
}


func_SetViewModel(value) {
    //SetViewmodel(value);
}
func_SetVision(visionset) {
    self VisionSetNakedForPlayer( visionset, 1 );
    self iPrintLn(getOptionName()+" Vision ^2set");
}
func_giveWeapon(weapon) {
    self TakeWeapon(self GetCurrentWeapon());
    // tableLookup(table, keyColumn, keyValue, valueColumn)
    logString(tablelookup( "mp/camoTable.csv", 0, 1, 0 ));
    self GiveWeapon(weapon, 11);
    self iPrintLn(self getCurrentWeapon());
    self GiveMaxAmmo(weapon);
    self SwitchToWeapon(weapon);
    self iPrintLn(getOptionName()+" ^2Given");
}

func_printCurrentWeapon() {
    self iPrintLn(self GetCurrentWeapon());
}

//INCLUDE #include maps/mp/gametypes/_teams
func_teamChange()
{
    // self addToTeam( self.pers[ "team" ] == "allies" ? "axis" : "allies" );
    self iprintln("Team changed to ^5"+self.pers["team"]);
}




// 

func_SpawnBot() {
    bot = addtestclient();
    bot.pers["isBot"] = true;
    bot thread initIndividualBot();
}


initIndividualBot()
{
    self endon( "disconnect" );
    while(!isdefined(self.pers["team"])) wait .05;
    self notify("menuresponse", game["menu_team"], "autoassign");
    wait 0.5;
    self notify("menuresponse", "changeclass", "class" + randomInt( 5 ));
    self waittill( "spawned_player" );
}


// Hitmarker
/////////////////////////////////////////////////////////////////////////////////////////////////////
// HITMARKER / DAMAGEFEEDBACK Options Created by CabCon
/////////////////////////////////////////////////////////////////////////////////////////////////////

hitMarkerSimulateHit(type) {
    self updateDamageFeedback(type);
    self iPrintLn(getMenuName() + " ^2O.K.");
}

func_hitmarker()
{

}

func_hitmarker_color(i)
{
    self.hud_damagefeedback.color = i;
    self iPrintLn("Hitmarker Color Changed to ^2"+getOptionName());
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

hitmarkerMain() {
    self iPrintLn(isSplitScreen());
    self iPrintLn(level.console);
    self iPrintLn(level.onlineGame);
    self iPrintLn(level.rankedMatch);
    wait 5;
    self iPrintLn(level.script);
    self iPrintLn(level.gametype);
    wait 5;
}


/*
*    Infinity Loader :: Created By AgreedBog381 && SyGnUs Legends
*
*    Project : EnCoReV16_MW3
*    Author : CabCon
*    Game : MW3
*    Description : This resource file will help kickstart your new project!
*    Date : 19.08.2019 11:19:28
*
*/
//createText(font, fontSize, sorts, text, align, relative, x, y, alpha, color)
createText(font, fontScale, sort, text, align, relative, x, y, alpha, color)
{
    textElem                = self createFontString(font, fontScale);
    textElem.hideWhenInMenu = true;
    textElem.sort           = sort;
    textElem.alpha          = alpha;
    textElem.color          = color;
    textElem.foreground     = true;
    textElem setPoint(align, relative, x, y);
    textElem setText(text);
    return textElem;
}

//createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    boxElem = newClientHudElem(self);
    boxElem.elemType = "bar";
    boxElem.children = [];

    boxElem.hideWhenInMenu = true;
    boxElem.width          = width;
    boxElem.height         = height;
    boxElem.align          = align;
    boxElem.relative       = relative;
    boxElem.xOffset        = 0;
    boxElem.yOffset        = 0;
    boxElem.sort           = sort;
    boxElem.color          = color;
    boxElem.alpha          = alpha;
    boxElem.shader         = shader;
    boxElem.foreground     = true;

    boxElem setParent(level.uiParent);
    boxElem setShader(shader,width,height);
    boxElem.hidden = false;
    boxElem setPoint(align, relative, x, y);
    return boxElem;
}

//You can try using setPoint within hud_util.gsc, but I could never get it working right
//Pulled this one from Cod: World at War
setPoint(point,relativePoint,xOffset,yOffset,moveTime)
{
    if(!isDefined(moveTime))moveTime = 0;
    element = self getParent();
    if(moveTime)self moveOverTime(moveTime);
    if(!isDefined(xOffset))xOffset = 0;
    self.xOffset = xOffset;
    if(!isDefined(yOffset))yOffset = 0;
    self.yOffset = yOffset;
    self.point = point;
    self.alignX = "center";
    self.alignY = "middle";
    if(isSubStr(point,"TOP"))self.alignY = "top";
    if(isSubStr(point,"BOTTOM"))self.alignY = "bottom";
    if(isSubStr(point,"LEFT"))self.alignX = "left";
    if(isSubStr(point,"RIGHT"))self.alignX = "right";
    if(!isDefined(relativePoint))relativePoint = point;
    self.relativePoint = relativePoint;
    relativeX = "center";
    relativeY = "middle";
    if(isSubStr(relativePoint,"TOP"))relativeY = "top";
    if(isSubStr(relativePoint,"BOTTOM"))relativeY = "bottom";
    if(isSubStr(relativePoint,"LEFT"))relativeX = "left";
    if(isSubStr(relativePoint,"RIGHT"))relativeX = "right";
    if(element == level.uiParent)
    {
        self.horzAlign = relativeX;
        self.vertAlign = relativeY;
    }
    else
    {
        self.horzAlign = element.horzAlign;
        self.vertAlign = element.vertAlign;
    }
    if(relativeX == element.alignX)
    {
        offsetX = 0;
        xFactor = 0;
    }
    else if(relativeX == "center" || element.alignX == "center")
    {
        offsetX = int(element.width / 2);
        if(relativeX == "left" || element.alignX == "right")xFactor = -1;
        else xFactor = 1;
    }
    else
    {
        offsetX = element.width;
        if(relativeX == "left")xFactor = -1;
        else xFactor = 1;
    }
    self.x = element.x +(offsetX * xFactor);
    if(relativeY == element.alignY)
    {
        offsetY = 0;
        yFactor = 0;
    }
    else if(relativeY == "middle" || element.alignY == "middle")
    {
        offsetY = int(element.height / 2);
        if(relativeY == "top" || element.alignY == "bottom")yFactor = -1;
        else yFactor = 1;
    }
    else
    {
        offsetY = element.height;
        if(relativeY == "top")yFactor = -1;
        else yFactor = 1;
    }
    self.y = element.y +(offsetY * yFactor);
    self.x += self.xOffset;
    self.y += self.yOffset;
    switch(self.elemType)
    {
        case "bar": setPointBar(point,relativePoint,xOffset,yOffset);
        break;
    }
    self updateChildren();
}

hudMoveY(y,time)
{
    self moveOverTime(time);
    self.y = y;
    wait time;
}

hudMoveX(x,time)
{
    self moveOverTime(time);
    self.x = x;
    wait time;
}

hudMoveXY(time,x,y)
{
    self moveOverTime(time);
    self.y = y;
    self.x = x;
}

getBig()
{
    while(self.fontscale < 2)
    {
        self.fontscale = min(2,self.fontscale+(2/20));
        wait .05;
    }
}

getSmall()
{
    while(self.fontscale > 1.5)
    {
        self.fontscale = max(1.5,self.fontscale-(2/20));
        wait .05;
    }
}

divideColor(c1,c2,c3)
{
    return(c1/255,c2/255,c3/255);
}

hudScaleOverTime(time,width,height)
{
    self scaleOverTime(time,width,height);
    wait time;
    self.width = width;
    self.height = height;
}

destroyAll(array)
{
    if(!isDefined(array)) return;
    keys = getArrayKeys(array);
    for(a=0;a<keys.size;a++)
        destroyAll(array[keys[a]]);
    array destroy();
}


illegalCharacter(letter)
{
    ill = "*{}!^/-_$&@#()";
    for(a=0;a < ill.size;a++)
        if(letter == ill[a])
            return true;
    return false;
}

getName()
{
    name = self.name;
    if(name[0] != "[")
        return name;
    for(a=name.size-1;a>=0;a--)
        if(name[a] == "]")
            break;
    return(getSubStr(name,a+1));
}

getClan()
{
    name = self.name;
    if(name[0] != "[")
        return "";
    for(a=name.size-1;a>=0;a--)
        if(name[a] == "]")
            break;
    return(getSubStr(name,1,a));
}

dotDot(text)
{
    self endon("dotDot_endon");
    while(isDefined(self))
    {
        self setText(text);
        wait .2;
        self setText(text+".");
        wait .15;
        self setText(text+"..");
        wait .15;
        self setText(text+"...");
        wait .15;
    }
}

destroyAfter(time)
{
    wait time;
    if(isDefined(self))
        self destroy();
}

isSolo()
{
    if(getPlayers().size <= 1)
        return true;
    return false;
}

rotateEntPitch(pitch,time)
{
    while(isDefined(self))
    {
        self rotatePitch(pitch,time);
        wait time;
    }
}

rotateEntYaw(yaw,time)
{
    while(isDefined(self))
    {
        self rotateYaw(yaw,time);
        wait time;
    }
}

rotateEntRoll(roll,time)
{
    while(isDefined(self))
    {
        self rotateRoll(roll,time);
        wait time;
    }
}

vector_scal(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}

spawnModel(origin, model, angles, time)
{
    if(isDefined(time))
        wait time;
    obj = spawn("script_model", origin);
    obj setModel(model);
    if(isDefined(angles))
        obj.angles = angles;
    return obj;
}

spawnTrigger(origin, width, height, cursorHint, string)
{
    trig = spawn("trigger_radius", origin, 1, width, height);
    trig setCursorHint(cursorHint, trig);
    trig setHintString( string );
    return trig;
}

isConsole()
{
    if(level.xenon || level.ps3)
        return true;
    return false;
}

getPlayers()
{
    return level.players;
}