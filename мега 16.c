#define GETBIT(data, index) ((data & (1 << index)) == 0 ? 0 : 1)
#include <mega16.h>
#include <1wire.h>
#include <ds18b20_.h>
#include <delay.h>
#define   BUT_OK      button==1
#define   BUT_STEP    button==2
#define   POWER       power
#define   ON          1
#define   OFF         0

//*********************************************************************************************/
unsigned char  error_ds18b20[], font_epp=2;

bit  mig, flg_min=0, bud_flg=0, but_flg=0,  zv_kn=0,  zv_chs=1, but_on=0, line=0, power=1, temp5, flg_ds18b20=0,
	pumpStatus=0, /*Состояние выхода насоса*/
	banya_is_complete=0, //готова ли баня
	needDrova=0,//Нужны ли дрова
    endSwitch=0, //Состояние концевиков  
    noticeBanya=1 //Уведомления о бане
;  
                     
unsigned char       meny=10, sek=0, chislo=26, mesec=10, god=20, den_nedeli, bud_temp, button, but_pause=0,  z, z1, bud, temp, temp1=0, temp2=0, t, flg_korr=1, speed=28,  font_=5,
                    delayBan=0,
                    delayTime=2,
                    str_sec=0,    
                    ekran            [24],         // Экранный  буфер
                    beg_info         [280],        // Бегущая строка в основном режиме 
                    rom_code         [2][9],       // массив с адресами найденых датчиков DS18B20
                    budilnik_Install [9],          // храним настройки будильников
                    budilnik_Interval[9],         // храним значение длительности сигнала будильника
                    lightTime=120,/*Время освещения в секундах */  
                    completeBeepTime=0,
                    timerLight=0,/*Время отчитываемое в системе на освещение*/
                    alertTime=10, // Время работы тревожного сигнала из бани в секундах
                    timerAlert=0, // отсчитываемое время  тревожного сигнала из бани в секундах 
                    timerDrova=0,
                    tone=0, //Выбор тона звучания 
                    timeToComplete=0, //Время до готовности бани 
                        ;
unsigned   int      budilnik_time    [9];          // храним время сработки будильников
unsigned char ds_ar[]={0,1,2,3,4,5,6,7,8}, // Датчики привязанные к названиям
                        sensorsReadCount=0; //

        
flash const unsigned char 
        den_nedeli_txt  [7][12]= {{25,24,23,15,14,15,21,38,23,18,20,255},   // Понедельник     //  названия дней недели
                                 {12,28,24,26,23,18,20,255},                // Вторник         //
                                 {27,26,15,14,10,255},                      // Среда           //
                                 {33,15,28,12,15,26,13,255},                // Четверг         //
                                 {25,41,28,23,18,32,10,255},                // Пятница         //
                                 {27,29,11,11,24,28,10,255},                // Суббота         //
                                 {12,24,27,20,26,15,27,15,23,38,15,255}},   // Воскресенье     //                                    
        den_nedeli_letter[7][2]= {{25,23},                     // Пн              //  сокращенные названия дней недели
                                 {12,28},                                   // Вт              //
                                 {27,26},                                   // Ср              //
                                 {33,28},                                   // Чт              //
                                 {25,28},                                   // Пт              //
                                 {27,11},                                   // Сб              //
                                 {12,27}},                                 // Вс              //            
        name_mesec_txt  [12][9]= {{41,23,12,10,26,41,255},                  // Января
                                 {30,15,12,26,10,21,41,255},                // Февраля
                                 {22,10,26,28,10,255},                      // Марта
                                 {10,25,26,15,21,41,255},                   // Апреля
                                 {22,10,41,255},                            // Мая
                                 {18,40,23,41,255},                         // Июня
                                 {18,40,21,41,255},                         // Июля
                                 {10,12,13,29,27,28,10,255},                // Августа
                                 {27,15,23,28,41,11,26,41,255},             // Сентября
                                 {24,20,28,41,11,26,41,255},                // Октября
                                 {23,24,41,11,26,41,255},                   // Ноября
                                 {14,15,20,10,11,26,41,255}},            // Декабря                        
        symbols [7][10][5]=
        {
                    {     
                        { 0x3E, 0x51, 0x49, 0x45, 0x3E },  // 0
                        { 0x00, 0x42, 0x7F, 0x40, 0x00 },  // 1
                        { 0x42, 0x61, 0x51, 0x49, 0x46 },  // 2
                        { 0x21, 0x41, 0x45, 0x4B, 0x31 },  // 3
                        { 0x18, 0x14, 0x12, 0x7F, 0x10 },  // 4
                        { 0x27, 0x45, 0x45, 0x45, 0x39 },  // 5
                        { 0x3C, 0x4A, 0x49, 0x49, 0x30 },  // 6
                        { 0x01, 0x71, 0x09, 0x05, 0x03 },  // 7
                        { 0x36, 0x49, 0x49, 0x49, 0x36 },  // 8
                        { 0x06, 0x49, 0x49, 0x29, 0x1E }  // 9
                    }
                    ,  
                    {     
                        //# if FONT==1    //  Шрифт цифр №1
                        { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
                        { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
                        { 0x61, 0x71, 0x59, 0x4F, 0x47 },
                        { 0x41, 0x49, 0x49, 0x7F, 0x7F },
                        { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
                        { 0x4F, 0x4F, 0x49, 0x79, 0x79 },
                        { 0x7F, 0x7F, 0x49, 0x79, 0x79 },
                        { 0x01, 0x71, 0x79, 0x0F, 0x07 },
                        { 0x7F, 0x7F, 0x49, 0x7F, 0x7F },
                        { 0x5F, 0x5F, 0x51, 0x7F, 0x7F }
                       // # endif
                    }
                    , 
                       {    
                            // # if FONT==2    //  Шрифт цифр №2
                            { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
                            { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
                            { 0x63, 0x73, 0x59, 0x4F, 0x47 },
                            { 0x63, 0x63, 0x49, 0x7F, 0x77 },
                            { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
                            { 0x6F, 0x6F, 0x49, 0x79, 0x79 },
                            { 0x7F, 0x7F, 0x49, 0x7B, 0x7B },
                            { 0x03, 0x73, 0x79, 0x0F, 0x07 },
                            { 0x77, 0x7F, 0x49, 0x7F, 0x77 },
                            { 0x6F, 0x6F, 0x49, 0x7F, 0x7F }
                            // # endif
                        }
                        ,  
                         {    
                            // # if FONT==3    //  Шрифт цифр №3
                            { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
                            { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
                            { 0x61, 0x71, 0x59, 0x4F, 0x47 },
                            { 0x41, 0x49, 0x49, 0x7F, 0x7F },
                            { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
                            { 0x4F, 0x49, 0x49, 0x79, 0x79 },
                            { 0x7F, 0x49, 0x49, 0x79, 0x79 },
                            { 0x01, 0x01, 0x01, 0x7F, 0x7F },
                            { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
                            { 0x1F, 0x11, 0x11, 0x7F, 0x7F }
                            //# endif
                        }
                            ,
                            {    
                                    // # if FONT==4    //  Шрифт цифр №4
                                    { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
                                    { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
                                    { 0x63, 0x71, 0x59, 0x4F, 0x47 },
                                    { 0x63, 0x41, 0x49, 0x7F, 0x7F },
                                    { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
                                    { 0x6F, 0x49, 0x49, 0x79, 0x79 },
                                    { 0x7F, 0x49, 0x49, 0x7B, 0x7B },
                                    { 0x03, 0x01, 0x01, 0x7F, 0x7F },
                                    { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
                                    { 0x1F, 0x11, 0x11, 0x7F, 0x7F }
                                    //# endif
                            }
                            ,
                                {         
                                        //  FONT==5    //  Шрифт цифр №5    
                                        { 0x3E, 0x7F, 0x41, 0x7F, 0x3E },
                                        { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
                                        { 0x62, 0x73, 0x59, 0x4F, 0x46 },
                                        { 0x22, 0x63, 0x49, 0x7F, 0x36 },
                                        { 0x18, 0x14, 0x12, 0x7F, 0x7F },
                                        { 0x2F, 0x6F, 0x45, 0x7D, 0x39 },
                                        { 0x3E, 0x7F, 0x49, 0x7B, 0x32 },
                                        { 0x03, 0x73, 0x79, 0x0F, 0x07 },
                                        { 0x36, 0x7F, 0x49, 0x7F, 0x36 },
                                        { 0x2E, 0x6F, 0x49, 0x7F, 0x3E }
                                }
                                ,
                                {         
                                    { 0x3E, 0x41, 0x41, 0x7F, 0x3E },
                                    { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
                                    { 0x62, 0x71, 0x59, 0x4F, 0x46 },
                                    { 0x22, 0x41, 0x49, 0x7F, 0x36 },
                                    { 0x18, 0x14, 0x12, 0x7F, 0x7F },
                                    { 0x2F, 0x45, 0x45, 0x7D, 0x39 },
                                    { 0x3E, 0x49, 0x49, 0x7B, 0x32 },
                                    { 0x03, 0x71, 0x79, 0x0F, 0x07 },
                                    { 0x36, 0x49, 0x49, 0x7F, 0x36 },
                                    { 0x26, 0x49, 0x49, 0x7F, 0x3E }
                                }
  },
  
  simvol_buk [][5]=
  {                 
	{ 0x7C, 0x12, 0x12, 0x7C, 0xAA },  // А  10
	{ 0x7E, 0x4A, 0x4A, 0x32, 0xAA },  // Б  11
	{ 0x7E, 0x4A, 0x4A, 0x34, 0xAA },  // В  12
	{ 0x7E, 0x02, 0x02, 0xAA, 0x00 },  // Г  13
	{ 0x60, 0x3C, 0x22, 0x3E, 0x60 },  // Д  14
	{ 0x7E, 0x4A, 0x4A, 0xAA, 0x00 },  // Е  15
	{ 0x24, 0x42, 0x4A, 0x34, 0xAA },  // З  16
	{ 0x66, 0x18, 0x7E, 0x18, 0x66 },  // Ж  17
	{ 0x7E, 0x10, 0x08, 0x7E, 0xAA },  // И  18
	{ 0x7C, 0x11, 0x09, 0x7C, 0xAA },  // И  19      
	{ 0x7E, 0x18, 0x24, 0x42, 0xAA },  // К  20
	{ 0x78, 0x04, 0x02, 0x7E, 0xAA },  // Л  21
	{ 0x7E, 0x04, 0x08, 0x04, 0x7E },  // М  22
	{ 0x7E, 0x08, 0x08, 0x7E, 0xAA },  // Н  23
	{ 0x3C, 0x42, 0x42, 0x3C, 0xAA },  // О  24
	{ 0x7E, 0x02, 0x02, 0x7E, 0xAA },  // П  25
	{ 0x7E, 0x12, 0x12, 0x0C, 0xAA },  // Р  26
	{ 0x3C, 0x42, 0x42, 0x24, 0xAA },  // С  27
	{ 0x02, 0x7E, 0x02, 0xAA, 0x00 },  // Т  28
	{ 0x4E, 0x50, 0x50, 0x3E, 0xAA },  // У  29
	{ 0x0C, 0x12, 0x7E, 0x12, 0x0C },  // Ф  30
	{ 0x66, 0x18, 0x18, 0x66, 0xAA },  // Х  31      
	{ 0x7E, 0x40, 0x40, 0x7E, 0xC0 },  // Ц  32
	{ 0x0E, 0x10, 0x10, 0x7E, 0xAA },  // Ч  33
	{ 0x7E, 0x40, 0x7E, 0x40, 0x7E },  // Ш  34
	{ 0x7E, 0x40, 0x7E, 0x40, 0xFE },  // Щ  35
	{ 0x02, 0x7E, 0x48, 0x30, 0xAA },  // Ъ  36
	{ 0x7E, 0x48, 0x30, 0x00, 0x7E },  // Ы  37
	{ 0x7E, 0x48, 0x30, 0xAA, 0x00 },  // Ь  38
	{ 0x24, 0x42, 0x4A, 0x3C, 0xAA },  // Э  39
	{ 0x7E, 0x08, 0x3C, 0x42, 0x3C },  // Ю  40
	{ 0x4C, 0x32, 0x12, 0x7E, 0xAA },  // Я  41
	{ 0x00, 0x00, 0xAA, 0xAA, 0x00 },  // пробел              42
    { 0x40, 0xAA, 0xAA, 0xAA, 0x00 },  // точка               43
     { 0x7E, 0x04, 0x08, 0x10, 0x7E  },  //  Буква N   44
    { 0x00, 0x00, 0x00, 0x00, 0x00 },  // "полный" пробел     45
    { 0x08, 0x08, 0x08, 0x08, 0x08 },  // минус               46
	{ 0x08, 0x08, 0x3E, 0x08, 0x08 },  // плюс                47
	{ 0x06, 0x09, 0x09, 0x06, 0xAA },  // знак градуса        48
    { 0x3E, 0x41, 0x41, 0x41, 0x22 },  // большая C           49
    { 0x04, 0x3F, 0x44, 0x20, 0xAA },  // прописная t         50
    { 0x08, 0x08, 0x08, 0xAA, 0x00 },  // маленький минус     51
    
    { 0x4C, 0x52, 0x52, 0x4C, 0xAA  },  //Продолжение для No.        52  
    
    { 0x00, 0xAA, 0xAA, 0xAA, 0xAA },  // точка внизу _       53
    { 0x00, 0x5F, 0xAA, 0x00, 0x00 },  // восклиц знак        54
    { 0x24, 0x48, 0x48, 0x24, 0x48 },  // знак примерно        55
    { 0x00, 0x24,0x00, 0x00, 0x00 },  // двоеточие        56  
    { 0x00, 0x18, 0x3c, 0x42, 0xff  }, // Иконка динамик 57

    },
dnei_v_mesc     []= {31,29,31,30,31,30,31,31,30,31,30,31},           // Количества дней по месяцам 
        banya_prognoz[]={11,10,23,41,42,11,29,14,15,28,42,55,42,12,42,255}, /*Баня будет  ~~ в */
        banya_add[]={25,24,14,20,18,23,38,42,14,26,24,12,10,42,255}, /*Подкинь дрова!*/ 
        pump_is_on[]={12,20,21,40,33,15,23,42,23,10,27,24,27,255},/*Включен насос*/
        sensors_txt[]={14,10,28,33,18,20,18,42,255},
        banya_txt[]={11,10,23,41,42,255},
        outside_txt[]={29,21,18,32,10,42,255}, 
        underground_txt[]={25,24,14,25,24,21,42,255}, 
        bez_banya_txt[]={11,15,16,29,22,23,10,41,42,11,10,23,41,42,255},
        home_txt[]={14,24,22,42,255},
        water_txt[]={12,24,14,10,42,255},
        budilnik_txt         [11]= {11,29,14,18,21,38,23,18,20,42,255},       // текст "Будильник"
        korekt_txt           [12]= {20,24,26,26,15,20,32,18,41,42,42,255},    // текст "Коррекция"
        nastroiki_txt       [11]= {29,27,28,10,23,24,12,20,18,42,255},       // текст "Установки"   
        den_txt              [5]= {14,15,23,38,255},                         // текст "День"
        data_txt             [5]= {14,10,28,10,255},                         // текст "Дата"
        god_txt              [4]= {13,24,14,255},                            // текст "Год"
        font_zifr_txt         []= {0,1,2,3,4,5,6,7,8,9,42,255},         // Набор цифер
        nastr_stroki_txt     [11]= {23,10,27,28,26,24,19,20,10,42,255},      // текст "Настройки"
        animation_txt[]={10,23,18,22,10,32,18,41,42,255},
        complete_txt[]={13,24,28,24,12,23,24,27,28,38,42,25,26,18,42,50,42,255},
        turning_txt[] ={12,20,21,40,33,15,23,18,15,42,25,26,18,42,50,42,255},
        delay_time_txt[] ={12,26,15,22,41,42,25,26,24,13,26,15,12,10,42,255},
          ;

eeprom signed int       korr_den=0, brigh_up_time=360, brigh_down_time=1380;
eeprom unsigned char    brigh_up=9, str_period=61,  str=0x1B; //0x18;

int
    time=718,
    sunriseToday=0,//Время восхода сегодня
	sunsetToday=0,//Время заката сегодня
    tempComplete=600,//  температура готовности бани
    temperature [6]={0,0,0,0,0,0}, 
    tempMin=300,
    historyTemp[5]={0,0,0,0,0}, //История градусов в бане для прогноза
    averageTemp[3]={0,0,0}; // Массив для усреденения значений от температуры 
unsigned char devices=0, simvol [58][5], animation=0;
unsigned   int   Interval , Interval_2, data1, str_time=0;   


//___________________________Возвращает абсолютное значение числа_____________________________________ 
signed int abs (signed int x)
{
if (x<0) x=(x*(-1));
return x;
}

//______вычислить день недели по дате(спасибо форумчанину DANKO c сайта "радиокот"за формулу  )_________
unsigned char Day_week (void) 
{
    unsigned char y=god, m=mesec, myday;
   if (m > 2) { m -= 2;       }
   else       { m += 10; y--; }
   myday = ((chislo + y + (y>>2) + ((31 * m) / 12)) % 7);
   return (myday) ? myday-1: 6;
}

//___________________________________________коррекция времени___________________________________________
void correkt (void)
{   
        if(korr_den<0) {
        TCNT2=255+((korr_den%10)*25);
         sek=59+((korr_den%600)/10); 
         if (sek==60) {sek=0;} 
            time=1439;
         }    
        else {
         TCNT2=25*(korr_den%10);
         sek=((korr_den%600)/10);
         } 
}

//____________________________Гасим индикацию. (регулирую яркость индикации)________________________________
interrupt [TIM0_COMP] void timer0_comp_isr(void)
{
    PORTD.7=0;
    PORTD.7=1;
}
        
//________Диамическая индикация.   вывод данных из экранного буфера на светодиодную матрицу_______________
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
        static unsigned char stroka=0, i=0,checkButton=0,checkEnd1=0; 
        static unsigned int pump_pause=0,endSwitch1Pause=0;
        bit pumpButtonClick=0;
        
        if (++stroka==8)  stroka=0; 
        PORTD.7=1;
        //включение напряжения на индикацию
        PORTD.6=1;
        //Здесь должен быть построчный запуск матрицы
        PORTC.1=0;
        for(i=0;i<=24;i++){   
         PORTC.0=1;  
         PORTA=0+(GETBIT((ekran [i]),stroka)<<stroka);
         PORTC.0=0;
        }       
        PORTC.1=1; 
        PORTD.7=0;   

        
		/*Отслеживание кнопки насоса*/
 		pumpButtonClick=PIND.5;
       	if(pumpButtonClick){
            pump_pause++;
       	        if(pump_pause>800 && !checkButton){
       		        pump_pause=0;   
                    checkButton=1;   
       		        pumpStatus=!pumpStatus; /*Смена состояния насоса*/
       		        PORTD.1=pumpStatus; //Включение/отключение насоса
       	        }            
                if(pump_pause>1000){pump_pause=801;}
        }
        else
        {   
            if(checkButton>0)
            {      
                checkButton=0;
                pump_pause=0;
            }
            //дребезг
            if(pump_pause<20)
       	    {
       		    pump_pause=0; 
       	    }
            else
       	    /*тревога*/
            {
                pump_pause=0;    
                timerAlert=alertTime;
            }
        
        }
        
        
        //Концевик дома
         if(PINC.4)
         {      endSwitch1Pause++;
                 if(endSwitch1Pause>800 && !checkEnd1)
                 {  
                        endSwitch1Pause=0;          
                        checkEnd1=1;
                        endSwitch=!endSwitch;
                 }     
                 if(endSwitch1Pause>900) endSwitch1Pause=801;
         }
         else
         {
            if(checkEnd1){
                checkEnd1=0;
                endSwitch1Pause=0;  
            }
            if(endSwitch1Pause>0)
            {
                endSwitch1Pause=0;
            }        
         }
         
         
       	//Если сработал концевик дома или в бане
       	if( endSwitch && timerLight==0 ){
       		timerLight=lightTime;
       	}
       	//Если время истекло отключаем концевики
       	if(timerLight==0 || endSwitch==0){    
            timerLight=0;
       		endSwitch=0;
       	}
        but_pause++;  if (but_pause==100)      { but_pause=0; but_on=1; }                 // если с момента прошлого нажатия кнопки прошло больше 0,3 сек - разрешаю очередное чтение кнопок
        if ((but_pause==30)&&(but_flg))        { but_flg=0; PORTB.5=0; TIMSK&=0xEF;}       // выключаю "писк" при нажатии кнопки      
        
        Interval++;   Interval_2++;                                                       //  отсчитываем интервал для бегущих строк и прочих нужд
}

//___________________________________Чтение состояния кнопок_______________________________________________
unsigned char  button_read (void)
{
    button=0;

    if ( (PIND.2==1 || PIND.4==1 ) && (but_on)){
        if(PIND.2==1){
            button=2;  
        }
        if(PIND.4==1){
            button=1;
        }
        but_on=0;  but_pause=0;
        
        if (zv_kn) {but_flg=1; TIMSK|=0x10;}// Если не отключен - короткий писк динамика при нажатии кнопки .
        if (bud_flg) {bud_flg=0; button=0;} // Выключаем (если был включен) сигнал будильника.  это нужно чтоб можно было выключить сигнал будильника просто нажатием любой кнопки.
        bud_flg=0;
    }
    return  button;
}

//_____________________выщитываем время, следующего запуска бегущей строки _________________________________
void str_pause (void)
{
    str_time=time+(str_period/60);
    str_sec=sek+(str_period%60);  if (str_sec >= 60) {str_sec=str_sec%60;  str_time++;} 
    if (str_time >=1440) {str_time-=1440;}
}



//______________________________________Копируем буквы из Flash памяти в ОЗУ
void font_cifri (void)
{  
        unsigned char temp,temp_srift,i;         
        for (temp=0; temp<61; temp++) {  
            if(temp<10){
                for (temp_srift=0; temp_srift<5; temp_srift++){
                    simvol[temp] [temp_srift]=symbols[font_][temp] [temp_srift];
                }
            }
            else{
                    for (i=0; i<5; i++){
                        simvol [temp] [i]= simvol_buk[temp-10] [i];
                    }    
            }
        }
}

//______Прерывание от компаратора(заходим сюда когда пропадает и когда появляется внешнее напряжение)______
interrupt [ANA_COMP] void ana_comp_isr(void)               
{
        char j=0;
        if(ACSR&0x20)                // если пропало внешнее питания
        { 
        banya_is_complete=1;
        POWER = OFF;                 // переходим на резервное питание от батареек 
        MCUCR=0b01110000;            // разрешаем усыплять контроллер по команде SLEEP (для мега16)
        TCCR0=0x00;                  // останавливаем Т/С0
        ADCSRA=0x00;                 // выключаю АЦП 
        TIMSK&=0x7f;                 // запрещаю прерывание по совпадению Т2
        ADMUX= 0b00100111;           // выключаю ИОН для АЦП
        PORTA=0;  DDRB=0b11110111;   // перевожу порты в состояние наменьшего потребления  
        PORTB=0; PORTC=0; PORTD=0;    
        }
        else                         // если  внешнее питания  появилось
        { 
        POWER = ON;                  // переходим на внешнее питание
        MCUCR=0b00110000;            // запрещаем усыплять контроллер по команде  SLEEP
        DDRB=0xE3;                   // возвращаем конфигурацию портов в рабочее состояние           
        TCCR0=0x03;                  // запускаем Т/С0
        ADCSRA=0b10000011;           // включаю АЦП 
        TIMSK|=0x80;                 // разрешаю прерывание по совпадению Т2
        ADMUX= 0b01100111;           // включаю ИОН для АЦП
        str_pause ();                // выщитываем время, следующего запуска бегущей строки  
        devices=w1_search(0xf0,rom_code);
            for(j=0;j<devices;j++){
                ds18b20_init( &rom_code[j][0], -45, 90, DS18B20_11BIT_RES );
            }     
        }

}

//__________________________________________пищу динамиком__________________________________________________
interrupt [TIM1_COMPA] void timer1_compa_isr(void)
{
 OCR1A = tone;     
 PORTB ^= (1 << 5);
}

//____________________________управляем яркостью индикатора________________________________
interrupt [TIM2_COMP] void timer2_comp_isr(void)
{

    if (brigh_down_time<brigh_up_time)// если время снижать яркость "раньше" времени восстанавливать  (в сутках)
        {
        if ( (time>=brigh_down_time)&&(time<brigh_up_time) )//
            {
            OCR0=(brigh_up*23)+1;     // пропорционально снижаем яркость индикатора.
            TIMSK|=0x02;              // разрешаем прерывание по совпадению Т0
            }
        else                          //
            {
            TIMSK&=0xFD;              // индикаторы горят в полную силу (запрещаем прерывание по совпадению ТО )   
            }
        }
    else                              // если время снижать яркость "позже" времени восстанавливать  (в сутках)
        {
        if ( (time<brigh_down_time)&&(time>=brigh_up_time) )//
            {
            TIMSK&=0xFD;              // индикаторы горят в полную силу (запрещаем прерывание по совпадению ТО )  
            }
        else                          //
            {
            OCR0=(brigh_up*23)+1;     // пропорционально снижаем яркость индикатора.
            TIMSK|=0x02;              // разрешаем прерывание по совпадению Т0 
            }
        }       
}



//____________________________________________отсчет времени________________________________________________
interrupt [TIM2_OVF] void timer2_ovf_isr(void)
{  
	mig++; 
    
    //подсчет секунд для тревоги  
    if(timerAlert>0){
		timerAlert--;
    }   
    //Подсчет секунд для освещения
    if(timerLight>0){
        timerLight--;
    }   
    //Подсчет секунд для добавления дров
    if(timerDrova>0){
        timerDrova--;
    }        
    
    if(completeBeepTime>0 && delayBan==0){
        completeBeepTime--;
    }
    
if (++sek==60) {    //  Инкреминируем секунды     
    if(delayBan>0){delayBan--;}         
    
	sek=0; time++; flg_min=1;
     if (time==1440){             
                banya_is_complete=0;
                needDrova=0;
                if(flg_korr)  {correkt(); flg_korr=0;  if(korr_den<0) goto m2;}  //  в 00-00, если еще сегодня не проводилась коррекция - провести коррекцию.    
                time=0;  chislo++; 
                if (chislo > dnei_v_mesc[mesec-1])
                {
                        chislo=1;
                         if (++mesec==13){
                                mesec=1; 
                                god++;
                         }
                }
                if ( (god%4) && (mesec==2) && (chislo==29) )  {mesec=3; chislo=1;}      // если НЕвысокосный год, то 29.02>>>>>01.03
                flg_korr=1;
                m2:                                           
                }
        }          
        
        if(sek%2==0){
            flg_ds18b20=1;
        }

}

//Обновление восхода и заката 
void sunrise_update()
{
float daySunrise[12]={-1.09, -2.1, -2.51, -2.43, -1.74, -0.16, 1.38, 1.90, 1.9,2, 1.93,0.83},
                     daySunset[12]={1.74,2.03,2,1.96,1.74,0.53,-1.22,-2.29,-2.6,-2.38,-1.6,0.12};
int 
	sunrise[12]={541,480,402,329,275,270,313,372,429,491,549,575},//Восход
	sunset[12]={1062,1121,1183,1242,1296,1312,1274,1203,1125,1051,1003,1007};//Закат 
    
int curMonth=mesec-1, neighborMonth=(curMonth==0) ? 11: curMonth-1;
 sunriseToday= sunrise[neighborMonth]+(int)(daySunrise[curMonth]*chislo);
 sunsetToday=sunset[neighborMonth]+(int)(daySunset[curMonth]*chislo);     
}


char timeToSymbol(int data1, char digit)
{
char symbol=45;
        if(digit==1){symbol=((data1/600)==0)? 45: (data1/600);}
        else if(digit==2){symbol= (data1%600)/60;}
        else if(digit==3){symbol=(data1%60)/10;}
        else if(digit==4){symbol=data1%10;} 
 return symbol;
}


//______________________загрузка в экранный буфер символов + мигающая точка в центре_________________________
 void ekran_cifri (unsigned  int data)
{  
    unsigned char i,point[5]={0,0,6,13,19};
    static unsigned char    Shift_zn;                          
    if (data != data1){
    if(Interval_2>40){
        Interval_2=0; 
        Shift_zn++;  
        if(Shift_zn==8) {
        Shift_zn=0;
        data1=data;
        }     
    }
    }
    else
    {
        Interval_2=0;
    }        
    
        for (temp=0; temp<5; temp++)
        {  
          for(i=1;i<5;i++){ 
            if( timeToSymbol(data,i) != timeToSymbol(data1,i) ) {   
                //Водопад
                if(animation==0){
                    ekran [temp+point[i]] =  (   (simvol [timeToSymbol(data1,i) ][temp]<<Shift_zn)  +   (simvol [timeToSymbol(data,i) ][temp]>>(8-Shift_zn))   );
                }                
                //Слева
                else if(animation==1 && Shift_zn==temp){                                                             
                    ekran [temp+point[i]] =simvol [timeToSymbol(data,i) ][temp]; 
                }                                                                                    
                //Замена
                else if(animation==2){ 
                        ekran [temp+point[i]] &= (~(1<<Shift_zn));    //Очистка бита
                        if ((simvol [timeToSymbol(data,i) ][temp] & (1<<Shift_zn)) == 0){
                                  ekran [temp+point[i]] |=(0<<Shift_zn);
                        }      
                        else{
                               ekran [temp+point[i]] |=(1<<Shift_zn);
                        }          
                }  
                //Сползание вниз влево
                else if(animation==3){    
                        ekran [temp+point[i]] &= (~(1<<Shift_zn));    //Очистка бита
                        if ((simvol [timeToSymbol(data,i) ][temp] & (1<<Shift_zn)) == 0){
                                  ekran [temp+point[i]] |=(0<<Shift_zn);
                        }      
                        else{
                               ekran [temp+point[i]] |=(1<<Shift_zn);
                        }      
                        if(Shift_zn==temp){
                                ekran [temp+point[i]] =simvol [timeToSymbol(data,i) ][temp];
                        }
                }         
                //Без анимации
                else{
                      ekran [temp+point[i]]=(simvol [timeToSymbol(data,i) ][temp]);  
                }
            }   
            else  {
                ekran [temp+point[i]]=(simvol [timeToSymbol(data,i) ][temp]);  
            }
        }
        }   
// перемигивание точек в основном режиме.
if (mig) {
    ekran [12]=0;
    ekran [11]=128;
}   
else {
    ekran [12]=128;  
    ekran [11]=0;
}
}

//___________________________загрузка в отределенное место экрана 1 символа_________________________________
 void ekran_1_figure (unsigned char x,unsigned char x1,)          
{                                                                                                                         
   unsigned char temp;                                                          
   for (temp=0; temp<5; temp++){
   if (simvol [x][temp]==0xAA) return;                                                                                                            
   ekran [temp+x1]=(simvol [x][temp])  +(128*mig*line);
   }
}

//_______________________________________Гасим весь экран__________________________________________________
void ochistka (void)
{
unsigned char temp=0;
while( temp<24) {ekran[temp++]=0  ;}
}

//_________________________________________установки__2_символа____________________________________________  
  unsigned  char ystanovki_2 (unsigned  char x,unsigned  char x1,unsigned  char x2)
  {
        unsigned  char temp;      
        while ( (button_read() != 2)  &&  POWER )  // POWER
        {
        if (BUT_OK) {x++;   if (x>x1) x=0;}                                                                                                                           
                for (temp=0; temp<5; temp++)
                {                                                                                                           
                ekran [temp+x2]  =(simvol [x/10][temp])   +(128*mig); 
                ekran [temp+x2+6]=(simvol [x%10][temp])   +(128*mig);
                }
        }
  ochistka();  return x;
  }
  
//___________________________________________установки______________________________________________________
  unsigned  int ystanovki_23_59 (unsigned  int x)
  {
  ochistka();
  ekran_1_figure((x%60)/10,13);  ekran_1_figure(x%10,19);
  x = (x%60)+   (ystanovki_2 ((x/60),23, 0))*60;
  ekran_1_figure(x/600,0);  ekran_1_figure((x/60)%10,6);
  x = (x/60*60)+(ystanovki_2 ((x%60),59,13));
  return x;
  }

//_________________________________________бегущая строка___________________________________________________
unsigned char beg_stroka (flash unsigned char x[],)
{         
  static unsigned char temp;
  for (temp=0; temp<23; temp++)  {  ekran[temp]=ekran[temp+1]; }
  if ((z==5)||(simvol[x[z1]][z]==0xAA)) {
    ekran[23]=0;
    z=0; z1++;
        if (x[z1]==255){
        z1=0;
        return 255;
        }
    }
    else{
        ekran[23]=simvol[x[z1]][z];
        z++;
    }
}  
 

unsigned char beg_stroka_not (unsigned char x[],)
{         
  static unsigned char temp,count=0,tryCount=0,j=0;
  char i=0;
  float     temperature_temp=0;  
  float  arifMin=0;
  for (temp=0; temp<23; temp++)  {  ekran[temp]=ekran[temp+1]; }
   if(ekran[temp]==0x00){
       count++;
   }
   else{
        count=0;
   }
   
  if(count>24 && flg_ds18b20){    
        if(tryCount<2){tryCount++;}         
        count=0;
        flg_ds18b20=0;                   
        #asm("cli");
        for ( i=0;i<devices;i++){
                error_ds18b20[i]++;                                                               // инкременируем счетчик ошибочных чтений  DS18B20 
                temperature_temp=ds18b20_read_temp (&rom_code[i][0]);                             // читаю датчик температуры DS18B20                    
                if (temperature_temp!=(-9999) && tryCount>1)                                                    // если температура прочиталась правильно,
                {                                          
                temperature[i]=temperature_temp*10;// temperature[i]+=5;// то сохраняем её значение в "temperature" 
                 
                    //Если это датчик от бани
                    if(i==ds_ar[0]){
                                averageTemp[sensorsReadCount++]=temperature[i];
                                //Расчет для безумной бани
                                if(sensorsReadCount==3){
                                    sensorsReadCount=0;
                                             //Заполнение истории показаний бани 
                                            for( j=0;j<4;j++) {
                                                historyTemp[j]=historyTemp[j+1];
                                            }
                                           
                                            arifMin=0;                         
                                            for( j=0;j<3;j++) {
                                                arifMin+=averageTemp[j];
                                            }
                                            historyTemp[4]=  arifMin/3;
                                   
                                            arifMin=0;                         
                                            for( j=0;j<3;j++) {
                                                arifMin+=historyTemp[j+1]-historyTemp[j];
                                            }
                                            arifMin/=4.0;
                                            //Прогноз для бани
                                            if(temperature[ds_ar[0]]<tempComplete && temperature[ds_ar[0]]>tempMin && banya_is_complete!=1){
                                                //Добавь дрова в печку                                                                
                                                if((((historyTemp[4]-historyTemp[3])+ (historyTemp[3]-historyTemp[2]))/2.0)<arifMin && historyTemp[4]<historyTemp[3] ){
                                                    needDrova=1; 
                                                    timerDrova=4;
                                                }
                                                else{
                                                    needDrova=0;
                                                }
                                                //Готовность бани в минутах + задержка 
                                                if(arifMin>0){                                     
                                                     timeToComplete=(int)((tempComplete-temperature[ds_ar[0]])/(arifMin))+delayBan;
                                                }
                                                banya_is_complete=0;
                                            }
                                            //Баня готова
                                            else if(temperature[ds_ar[0]]>=tempComplete && banya_is_complete!=1){
                                                needDrova=0;              
                                                completeBeepTime=3;
                                                banya_is_complete=1; 
                                                delayBan=delayTime;
                                            }   
                                            else if(banya_is_complete==1){
                                                needDrova=0;
                                            }else
                                            {
                                                //обнуление истории бани
                                                for(j=0;j<5;j++) {historyTemp[j]=-100;}
                                                needDrova=0;
                                            }
                    }
                }                 
                error_ds18b20[i]=0;                                   // обнуляем счетчик ошибочных чтений  DS18B20 
                }
                if(error_ds18b20[i]==255)  temperature[i]=-999;                                   // если датчик DS18B20 за 5 мин ни разу правильно не прочитался, то подаём сигнал тревоги(выводим температуру -99,9 градуса)
                ds18b20_convert_temp(&rom_code[i][0]);                                            // команда на измерение температуры   
        }           
        #asm("sei");
  }
  if ((z==5)||(simvol[x[z1]][z]==0xAA)) {
    ekran[23]=0;
    z=0; z1++; 

        if (x[z1]==255){
        z1=0;
        return 255;
        }
    }
    else{
        ekran[23]=simvol[x[z1]][z];
        z++;
    }
}  
 

//__________________________________вывод неподвижного текста_______________________________________________
void txt_ekran (flash unsigned char x[],)
{
unsigned char temp =0,  temp1=0, temp2=0;

    for(temp=0;temp<24;temp++)
    {
    if ((temp2==5) || (simvol[x[temp1]][temp2] == 0xAA)) {ekran[temp]=0;   temp2=0; temp1++;} else {ekran[temp]=simvol[x[temp1]][temp2]; temp2++;}
    if (x[temp1]==255) return ; 
    }
}


//*****************************************************************************************************************//
//*****************************************************************************************************************//
//*****************************************************************************************************************//
//*****************************************************************************************************************//
void main(void)
{
int timeComplete=0;
char j=0,i=0,moonDay=1,moonYear=17, temp5;
  
 
PORTA=0x00; DDRA=0xFF;
PORTB=0x00; DDRB=0xE3; 
PORTC=0x00; DDRC=0x3F;
PORTD=0x00; DDRD=0xC0;                                                    

TCCR0=0x03;           // Частота Т0 125,000 kHz   (8000000/64)
OCR0=254;             //

TCCR1B=0x0C;          // Частота Т1 125,000 kHz   (8000000/64)
OCR1A=20;

ASSR=0x08;            // Такт от ног TOSC1,2 с кварцем на 32768
TCCR2=0x05;           // 32768/128=256 
OCR1A=127;            //

TIMSK=0xC3;           // Конфигурирую прерывания от таймеров 

ACSR= 0x48;           // Компаратор.  
SFIOR=0x00;

MCUCR|=0b00110000;    // выбираю режим пониженного энергопотребления - Power Sawe

ADCSRA=0b10000011;    // разрешаю АЦП.  частота преобразования - 1МГЦ.
ADMUX= 0b01100111;    // ИОН-AVcc.  меряем на пин 7, порт А 

#asm                                // настраиваю шину   1 Wire
   .equ __w1_port=0x18 ;PORTB       // на работу с портов В
   .equ __w1_bit=4                  // бит 4
#endasm

for (temp=0;temp<9;temp++){budilnik_time [temp] = budilnik_Install [temp] = budilnik_Interval[temp]= 0;}  bud_flg=0;   // "выключаем" все будильники
den_nedeli=Day_week ();             // Вычисляем день недели

brigh_up=9;   // 
sunrise_update();
ochistka();  // Очищаем весь зкран
//#asm("cli")
devices=w1_search(0xf0,rom_code);
for(j=0;j<devices;j++){
    ds18b20_init( &rom_code[j][0], -45, 90, DS18B20_11BIT_RES );
}
#asm("sei")

if(font_epp<0 || font_epp>6) font_epp=5;
if (str_period <0 || str_period >255) str_period =15;
font_=font_epp;
font_cifri();

ochistka();    // Очищаем весь зкран
str_pause ();  // Вычисляем время запуска бег строки.

//*****************************************************************************************************************//
//*****************************************************************************************************************//

while (1)
{
button_read();   // Опрос кнопок
switch (meny)
        {       
        case 10: //______основной режим 
                ekran_cifri(time);  // отображаем время      
                //______запуск бегущей строки        
                if ( ((sek >= str_sec) && (time == str_time))    &&  (str != 0) )   {meny=11 ;z=0; z1=0; temp2=str;}           // Запускаем бегущую строку                
                if (BUT_STEP) {meny=30; z=0; z1=0; ochistka();  bud_flg=0;data1=(((time-(time/60*60))*60)+sek);}
                if (BUT_OK)   {meny=11 ;z=0; z1=0; temp2=0x18;}
        break;
        
        case 11: //______Формируем и вывожу бег строку.
                t=0; temp1=0;  den_nedeli=Day_week ();
                beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;
                /*Уведомление о включеном насосе*/
             	if(pumpStatus)
            	{
            		temp1=t;            
                    while (pump_is_on[(t-temp1)] != 255)      
					{     
                        beg_info[t]=pump_is_on[t++-temp1];
                    }
            	}
 				beg_info[t++] = 42; 
                
                
                /*Отображение температуры в бане */
                if(historyTemp[0]>tempMin && banya_is_complete==0){
					//  Баня вывод прогноза
                	if(timeToComplete+time<1440 && timeToComplete>0){
	                	temp1=t;
                        while (banya_prognoz[(t-temp1)] != 255)      
						{     
                                beg_info[t]=banya_prognoz[t++-temp1];
                        }
	                	timeComplete=time+timeToComplete;     
                                  
						//составление прогноза готовности бани
                        for(i=1;i<5;i++){
                             beg_info[t++]=timeToSymbol(timeComplete,i);             //    десятки часов     
                             if(i==2){
                                   beg_info[t++]=43;  
                             }
                        }

                	}              
                    
                    beg_info[t++] = 42;
                	//Уведомление о необходимости добавления дров
                	if(needDrova==1)
                	{
                		temp1=t;
                        while (banya_add[(t-temp1)] != 255)      
						{     
                            beg_info[t]=banya_add[t++-temp1];
                        } 
                	}  
                    
                beg_info[t++] = 42;
                }
                

                if (temp2 & 0x01)// если "день недели" нужно выводить
                        {
                        temp1=t;
                        while (den_nedeli_txt[den_nedeli][t-temp1] != 255)         // 
                                {                                              //
                                beg_info[t]=den_nedeli_txt[den_nedeli][t++-temp1]; //
                                } beg_info[t++] = 42;                          //  пробел
                        }                             
                if (temp2 & 0x02)                                              //  Если "дату" нужно выводить
                        {                                                      //
                        if (chislo>9) {beg_info[t++]=chislo/10;}               //  Если число больше 9, выводим "десятки" числа
                        beg_info[t++]=chislo%10;                               //  Выводим "Единицы" числа
                        beg_info[t++]=42;                                      //  Пробел                      
                        temp1=t;
                        while (name_mesec_txt[mesec-1][(t-temp1)] != 255)      //  Выводим месяц
                                {     
                                beg_info[t]=name_mesec_txt[mesec-1][t++-temp1];
                                } beg_info[t++] = 42;                          // пробел
                        } 
                if (temp2 & 0x04)                                              //  Если "Год" нужно выводить
                        {
                        beg_info[t++]=2;                                       // "Тысячи" года (2)
                        beg_info[t++]=0;                                       // "Сотни"  года (0)
                        beg_info[t++]=(god%100)/10;                            // "Десятки" года
                        beg_info[t++]=god%10;                                  // "Единицы" года
                        beg_info[t++]=13;                                      // "Г"
                        beg_info[t++]=42; beg_info[t++]=42;                    // 2 пробела
                        }
                        
                        for (temp1=0;temp1<devices;temp1++)                                         // если датчиков температуры больше 2х
                        {
                            temp5=t;                
                        if(temp1==0){
                            while (banya_txt[(t-temp5)] != 255)      
                            {     
                                     beg_info[t]=banya_txt[t++-temp5];
                            }
                        }
                        else if(temp1==1){
                            while (outside_txt[(t-temp5)] != 255)      
                            {     
                                     beg_info[t]=outside_txt[t++-temp5];
                            }
                        } 
                        else if(temp1==2){
                            while (water_txt[(t-temp5)] != 255)      
                            {     
                                     beg_info[t]=water_txt[t++-temp5];
                            }
                        }
                        else if(temp1==3 || temp1==4){
                            while (underground_txt[(t-temp5)] != 255)      
                            {     
                                     beg_info[t]=underground_txt[t++-temp5];
                            }
                            beg_info[t++]=44;
                            beg_info[t++]=52; 
                            
                            if(temp1==3){       
                                beg_info[t++]=1;
                            }  
                            else{ 
                                beg_info[t++]=2;
                            }
                            beg_info[t++]=42;
                        } 
                        else if(temp1==5){
                            while (home_txt[(t-temp5)] != 255)      
                            {     
                                     beg_info[t]=home_txt[t++-temp5];
                            }
                        }
                        beg_info[t++]=56;  
                         
                        if (temperature[ds_ar[temp1]]!=0)  {
                             if (temperature[ds_ar[temp1]]<0)
                                beg_info[t++]=51;  
                             else beg_info[t++]=47;           // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
                        }
                        if (abs(temperature[ds_ar[temp1]])>99) {beg_info[t++]=(abs(temperature[ds_ar[temp1]])/100);}// Если темп >10,  выводим "десятки" температуры 
                        beg_info[t++]=(abs(temperature[ds_ar[temp1]])%100)/10;                               // Выводим "единицы температуры"
                        // если температура  нужна с десятыми - раскомментируйте две строки ниже
                        beg_info[t++]=43;                                                          // Разделительная точка
                        beg_info[t++]=abs(temperature[ds_ar[temp1]])%10;                                  // Десятые доли градуса.
                        beg_info[t++]=48;                                                             // Знак градуса     
                        beg_info[t++]=42;        //пробел
                        } 

                //вывод времени восхода
                beg_info[t++]=12;beg_info[t++]=24;beg_info[t++]=27;
                beg_info[t++]=31;beg_info[t++]=24;beg_info[t++]=14;beg_info[t++]=56;
                        
                        for(i=1;i<5;i++){     
                            if(i==1){
                                if(sunriseToday/600!=0){ beg_info[t++]=timeToSymbol(sunriseToday,i);}    
                            }else{
                                beg_info[t++]=timeToSymbol(sunriseToday,i);             //    десятки часов 
                            }     
                             if(i==2){
                                   beg_info[t++]=43;  
                             }
                        } 
                        //    десятки часов       
                 beg_info[t++]=42;            
                 
                //вывод времени заката
                beg_info[t++]=16;beg_info[t++]=10;beg_info[t++]=20;
                beg_info[t++]=10;beg_info[t++]=28;beg_info[t++]=56;
                     
                
                        for(i=1;i<5;i++){     
                            if(i==1){
                                if(sunsetToday/600!=0){ beg_info[t++]=timeToSymbol(sunsetToday,i);}    
                            }else{
                                beg_info[t++]=timeToSymbol(sunsetToday,i);             //    десятки часов 
                            }     
                             if(i==2){
                                   beg_info[t++]=43;  
                             }
                        } 
                        
                beg_info[t++]=42;
                
                //вывод лунных суток
                moonDay=1;  
                for(moonYear=18;moonYear<=god; moonYear++)
                {
                       moonDay+=11;
                       if(moonDay>30){
                            moonDay-=30;
                       }
                }
                moonDay=chislo+mesec+moonDay;
                if(moonDay>30){
                    moonDay-=30;
                }
                if(moonDay>=30 || moonDay<=0) {moonDay=1;} 
                if(moonDay>9){
                    beg_info[t++]=moonDay/10;          
                    beg_info[t++]=moonDay%10;  
                }
                else{
                      beg_info[t++]=moonDay;  
                }          
                
                 beg_info[t++]=46; beg_info[t++]=19;                                                                   
                beg_info[t++]=42;
                beg_info[t++]=21;beg_info[t++]=29;beg_info[t++]=23;
                beg_info[t++]=23;beg_info[t++]=37;beg_info[t++]=19;beg_info[t++]=42;
                beg_info[t++]=14;beg_info[t++]=15;beg_info[t++]=23;beg_info[t++]=38;   
                beg_info[t++]=42;
                beg_info[t++]=42;
                
           
                beg_info[t++]=timeToSymbol(time,1);  //    десятки часов
                beg_info[t++]=timeToSymbol(time,2);         //    единицы часов
                beg_info[t++]=43;                    //    разделительная точка
                beg_info[t++]=timeToSymbol(time,3);          //    десятки минут
                beg_info[t++]=timeToSymbol(time,4);               //    единицы минут
                beg_info[t]=255;                     //    метка конца "бегущей строки"
                

                if (Interval >= speed){
                    Interval=0; 
                    if (beg_stroka_not(beg_info)==255){
                        str_pause ();
                        meny=10; 
                        ochistka(); 
                        data1=time;
                    }
                }//  если строка полностью пробежала
                
                if (BUT_STEP) {meny=30; z=0; z1=0; ochistka();} 
                if (BUT_OK)   {z=0; z1=3; temp=0x0F; ochistka();}


        break;                                                                         
        
        //****************************Установки будильников*********************************** 
        case 30: //  На экране текст - "Будильник"  
            if (Interval>=speed)  {Interval=0;   beg_stroka(budilnik_txt);}
            if (BUT_STEP) {meny=40;z=0; z1=0;ochistka();}
            if (BUT_OK)   {ochistka(); bud=0; temp=0; meny=31;}
        break;
        case 31: //  выбираем номер будильника
            if (BUT_STEP) {meny=32;}
            if (BUT_OK  ) {bud++; if (bud==9) bud=0;  }
            ekran_1_figure(11,1); line=1; ekran_1_figure(bud+1,7); line=0; ekran_1_figure(((budilnik_Install[bud] & 0x80) ? (47):(46)),17);
        break;
        case 32: //  включаем или отключаем его.  если отключили - переходим в режим "часы"
            if (BUT_STEP)                       
                    {
                    if (budilnik_Install[bud] & 0x80)    // если текущий будильник включен
                        {
                        budilnik_time[bud]= ystanovki_23_59 (budilnik_time[bud]);     // устанавливаем время сработки будильника
                            if (bud<3){budilnik_Install[bud] = 0xFF; goto m1;}        // если будильник №1-3 то установки "по дням недели" не производим, и переходим сразу к настройке длительности сигнала этого будильника
                            else {temp=0;  meny=33;}                                  // если будильник №4-9 то перехъодим к настройке будильника на сработку в определенные дни                                         
                        }
                    else {str_pause (); meny=10;}   ochistka();  break;               // если текущий будильник отключен - переходим в режим "часы"
                    }
            if (BUT_OK )  {budilnik_Install[bud] ^= 0x80;}                            //  каждое нажатие включает/отключает конкретный будильник (устанавливает/сбрасывает в 1 бит7)
            ekran_1_figure(11,1); ekran_1_figure(bud+1,7); line=1; ekran_1_figure(((budilnik_Install[bud] & 0x80) ? (47):(46)),17); line=0;
        break;
        case 33:  //  Настраиваем будильник на сработку в определенные дни, и длительность его сигнала.
            ekran_1_figure (den_nedeli_letter[temp][0],0);  ekran_1_figure (den_nedeli_letter[temp][1],6);// вывожу названия дней недели. (массив "beg_info" содержит название дня недели)   
            ekran_1_figure (((budilnik_Install[bud] & (1 << temp)) ? 47:46),17);                          // вывожу знак "+" или "-"  обозначающий  вкл./выкл. будильника.
            
            if (BUT_STEP) {temp++; ochistka();                                                            // "перебираю"  дни недели для будильника
                          if (temp==7){ m1: meny=10; budilnik_Interval[bud] = ystanovki_2(1,15,8); }      //  если все дни недели установлены,  задаю время звучания сигнала.
                          }
            if (BUT_OK){(budilnik_Install[bud]) ^= (1 << temp);}                                           // включаю/отключаю будильник в конкретный день недели.
        break;             
        case 40: //*********************Установка времени и даты**************************** 
                if (Interval>=speed)  {Interval=0; beg_stroka(nastroiki_txt);}
                if (BUT_STEP) {meny=50; z=0; z1=0; ochistka();}
                if (BUT_OK)
                        {
                        time   =ystanovki_23_59(time);
                        ochistka();
                        ekran_1_figure(33,1);          ekran_1_figure(43,6);
                        chislo =ystanovki_2 (chislo,31, 13);
                        ekran_1_figure(22,1);          ekran_1_figure(43,7);
                        mesec  =ystanovki_2 (mesec, 12, 13);
                        ekran_1_figure(13,1);          ekran_1_figure(43,5);
                        god    =ystanovki_2 (god,   99, 13);
                        button=0;meny=10;ochistka(); temp=0; data1=time; str_pause ();
                        }
        break;
        
        case 48: // настройка шрифта 
            if (Interval>=speed)  {Interval=0; beg_stroka( font_zifr_txt);} 
            if (BUT_STEP)   {z=0; z1=0; ochistka();temp=12; if(font_epp!=font_)font_epp=font_; meny=10;break; } 
            if (BUT_OK)  { ochistka();font_++;  if (font_>6) font_=0; 
                           font_cifri ();ekran_1_figure(font_,10); delay_ms(1000);z=0; z1=0;  t=0; temp1=0; ochistka();
                             } break;
        break;   
        

        
        //*******Настройка бег строки. Выбираем какую информацию будем выводить с помощью бег. строки********** 
        case 50: // на экране текст - "Коррекция"
               if (Interval>=speed)  {Interval=0;   beg_stroka(nastr_stroki_txt);} 
               if (BUT_STEP) {meny=70; z=0; z1=0; ochistka();}                      
               if (BUT_OK)   {meny=51; ochistka(); temp=0;}
        break;
        case 51:
                if (BUT_STEP) {temp++; ochistka();}
                switch (temp)
                        {
                        case 0:  if (BUT_OK){str ^= (1 << 0);}   ekran_1_figure (((str & 0x01) ? 47:46),19);   txt_ekran(den_txt);            break;
                        case 1:  if (BUT_OK){str ^= (1 << 1);}    txt_ekran(data_txt); ekran_1_figure (((str & 0x02) ? 47:46),19);             break; 
                        case 2:  if (BUT_OK){str ^= (1 << 2);}   ekran_1_figure (((str & 0x04) ? 47:46),19);   txt_ekran(god_txt);            break; 
                        case 3:  if (BUT_OK){zv_chs++;       }   ekran_1_figure (((zv_chs) ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(33,9); ekran_1_figure(27,14); break;
                        case 4:  if (BUT_OK){zv_kn++;        }   ekran_1_figure (((zv_kn)  ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(20,9); ekran_1_figure(23,14); break;
                        case 5: if (BUT_OK){ochistka();z=0; z1=0;meny=48;break;}  ; ekran_1_figure(34,0); ekran_1_figure(26,6); ekran_1_figure(18,11); ekran_1_figure(30,16);ekran_1_figure(28,21); break;
                        case 6:  meny=52; temp=speed; break;
                        }
        break;
        case 52: // настройка скорости бегущей строки
            if (Interval>=temp)  {Interval=0;   beg_stroka_not(beg_info);} 
            if (BUT_OK)  {temp+=3;  if (temp>=60) {temp=9;}}
            if (BUT_STEP)   {speed=temp; meny=54; ochistka();}
        break;                                                                                                          
        
        case 54: // установка времени включения и выключения пониженной яркости ()
            TIMSK&=0x7F;         //  выключаю "автоматическое" изменение яркости.  (нужно для того, чтоб яркость не "пригала" во время настройки)
            brigh_down_time=ystanovki_23_59(brigh_down_time); // установка времени включения пониженной яркости
            ochistka();
            brigh_up_time=ystanovki_23_59(brigh_up_time);     // установка времени ВЫключения пониженной яркости
            ochistka();
            meny=55;
        break;    
        case 55: // установка уровня пониженной яркости                     
            ekran_1_figure(41,0);  
            ekran_1_figure(26,5);
            ekran_1_figure(20,10);
            ekran_1_figure(brigh_up,18);
            TIMSK|=0x02;                // включаю регулировку яркости индикаторов(разрешаю прерывание по совпадению Т0)
            OCR0=(brigh_up)*23+5;       // яркость экрана в зависимости от значения   brigh_up
            if (BUT_OK)  {brigh_up++; if(brigh_up==10) brigh_up=0;} //
            if (BUT_STEP)   {  meny=57; TIMSK|=0x80; ochistka();}   //
        break;   
        case 57: // Настройка периода запуска  бегущей строки
        temp=str_period;
        ekran_1_figure( (temp%60)/10,13);         
        ekran_1_figure((temp%60)%10,19);
        temp=60*(ystanovki_2 (temp/60,3,0) );
        ekran_1_figure(0,0);          ekran_1_figure(temp/60,6);
        temp=temp+(ystanovki_2 (str_period%60,59,13));
        str_period=temp;
        str_pause ();  meny=58; z=0;z1=0;
        break;
              
        case 58:
            if (Interval>=speed)  {Interval=0;   beg_stroka(animation_txt);}         
            if (BUT_OK)  {meny=59;ochistka();}  
            if (BUT_STEP)   {meny=10;} 
        break; 
               
        case 59: //Настройка    анимации
            ekran_cifri(((time-(time/60*60))*60)+sek);
            if (BUT_STEP) {str_pause ();  meny=10;}
            if (BUT_OK)   {if(++animation>3){animation=0;} ochistka();ekran_1_figure(animation,8); delay_ms(1000);ochistka(); }
        break;
        
        //**************************Установка параметров для бани***************************
        //На экране  Безумная баня
        case 70:
            if (Interval>=speed)  {Interval=0;   beg_stroka(bez_banya_txt);}         
            if (BUT_OK)  {meny=71; z=0; z1=0;  ochistka();}  
            if (BUT_STEP)   {meny=80; z=0; z1=0;   ochistka();} 
        break;  
        
        //Температура готовности
        case 71:
            if (Interval>=speed)  {Interval=0;   beg_stroka(complete_txt);}         
            if (BUT_OK)  {meny=72;ochistka();}  
            if (BUT_STEP)   {meny=73; z=0; z1=0;   ochistka();} 
        break;  
        case 72:  
        
            ekran_1_figure((tempComplete/100),0);
            ekran_1_figure((tempComplete%100)/10,6);     
            ekran_1_figure(48,13);  
            ekran_1_figure(49,19);
            if (BUT_OK)  {tempComplete+=10; if(tempComplete>990){tempComplete=20;}}  
            if (BUT_STEP)   {meny=71;  z=0; z1=0;ochistka();} 
        break;
        //Минимальная температура
        case 73:
            if (Interval>=speed)  {Interval=0;   beg_stroka(turning_txt);}         
            if (BUT_OK)  {meny=74;ochistka();}  
            if (BUT_STEP)   {meny=75; z=0; z1=0;   ochistka();} 
        break;       
                           
        case 74:   
            ekran_1_figure((tempMin/100),0);
            ekran_1_figure((tempMin%100)/10,6);   
            ekran_1_figure(48,13);  
            ekran_1_figure(49,19);
            if (BUT_OK)  {tempMin+=10;if(tempMin>=tempComplete){tempMin=10;}}    
            if (BUT_STEP)   {meny=73;  z=0; z1=0;ochistka();}
        break;     
                      
        //+ минуты для прогрева 
        case 75:
            if (Interval>=speed)  {Interval=0;   beg_stroka(delay_time_txt);}         
            if (BUT_OK)  {meny=76;ochistka();}  
            if (BUT_STEP)   {meny=77; z=0; z1=0;   ochistka();} 
        break;
        case 76:
            ekran_1_figure((delayTime/10),0);
            ekran_1_figure((delayTime%10),6); 
            ekran_1_figure(22,13);  
            ekran_1_figure(43,19);
            if (BUT_OK)  { if(++delayTime>59){delayTime=0;} }  
            if (BUT_STEP)   {meny=75;  z=0; z1=0; ochistka();}
        break; 
            
        //Звуковые уведомления безумной бани
        case 77: 
            ekran_1_figure(45,0);    
            ekran_1_figure(57,8);
            ekran_1_figure(((noticeBanya==0)?46:47),14); 
            if (BUT_OK)  {noticeBanya=abs(noticeBanya-1); ochistka();}  
            if (BUT_STEP)   {meny=70; z=0; z1=0; if(noticeBanya==1){banya_is_complete=0;} ochistka();}
        break;




        //**************************Настройка коррекции хода*******************************
        case 80: // на экране текст - "Коррекция"
            if (Interval>=speed)  {Interval=0;   beg_stroka(korekt_txt);} 
            if (BUT_STEP) {str_pause ();  meny=90; z=0; z1=0; ochistka();}
            if (BUT_OK)   {meny=81; ochistka();}
        break;
        case 81: // отображаем секунды.  по нажатию кнопки "ОК" - обнуляем секунды
        mig=1;
        ekran_cifri(((time-(time/60*60))*60)+sek);
        if (BUT_STEP) {meny=82; ochistka();}
        if (BUT_OK)   {if (sek>40) {time++; if (time==1440) time=0;}  sek=0; TCNT2=0;}
        break;
        case 82: // Установка секунд коррекции    
            if (BUT_STEP) {meny=83;}
            if (BUT_OK)   {korr_den=((korr_den<0)?(korr_den-=10):(korr_den+=10));if(abs(korr_den)>599){korr_den=korr_den%10;}}
            ekran_1_figure(((korr_den<0)?46:47),0);  
            line=1; ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12); 
            line=0; ekran_1_figure((abs(korr_den)%10),19); 
        break;
        case 83: // Установка десятых долей секунд коррекции
            if (BUT_STEP) { meny=84;}
            if (BUT_OK)   {if(korr_den<0){korr_den--;if(korr_den%10==0)korr_den+=10;}else{korr_den++;if(korr_den%10==0)korr_den-=10;}}
            ekran_1_figure(((korr_den<0)?46:47),0);  ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12); 
            line=1; ekran_1_figure((abs(korr_den)%10),19);  line=0;
        break;
        case 84: // Установка "знака" коррекции 
            if (BUT_STEP) {str_pause (); meny=10;}
            if (BUT_OK)   {korr_den = (korr_den * (-1));} 
            line=1; ekran_1_figure(((korr_den<0)?46:47),0);  
            line=0; ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12); ekran_1_figure((abs(korr_den)%10),19); 
        break;  
        
        
        
        
        
        
        
        
        //*************************Подбор датчика*****************************
        case 90:
            if (Interval>=speed)  {Interval=0;   beg_stroka(sensors_txt);} 
            if (BUT_STEP) {str_pause ();  meny=10; ochistka();}
            if (BUT_OK)   {meny=91; z=0; z1=0;  j=0; ochistka();}
        break;      
        
        //Выбор участка
        case 91:    
                t=0;       
                temp1=t;
                if(j==0){
                    while (banya_txt[(t-temp1)] != 255)      
                    {     
                             beg_info[t]=banya_txt[t++-temp1];
                    }
                }
                else if(j==1){
                    while (outside_txt[(t-temp1)] != 255)      
                    {     
                             beg_info[t]=outside_txt[t++-temp1];
                    }
                } 
                else if(j==2){
                    while (water_txt[(t-temp1)] != 255)      
                    {     
                             beg_info[t]=water_txt[t++-temp1];
                    }
                }
                else if(j==3 || j==4){
                    while (underground_txt[(t-temp1)] != 255)      
                    {     
                             beg_info[t]=underground_txt[t++-temp1];
                    }             
                     beg_info[t++]=44;
                     beg_info[t++]=52;
                     
                            if(j==3){       
                                beg_info[t++]=1;
                            }  
                            else{ 
                                beg_info[t++]=2;
                            }
                            beg_info[t++]=42;
                } 
                else if(j==5){
                    while (home_txt[(t-temp1)] != 255)      
                    {     
                             beg_info[t]=home_txt[t++-temp1];
                    }
                }           
                beg_info[t]=255;
                
            if (Interval>=speed)  {Interval=0;   beg_stroka_not(beg_info);}
            if (BUT_OK) {meny=92; ochistka();}
            if (BUT_STEP)   { if(++j>5){j=0; meny=90;}  z=0; z1=0;ochistka();}
        break;   
        //Выбор датчика
        case 92:            
            ekran_1_figure(14,0); 
            ekran_1_figure(43,6);   
            ekran_1_figure(44,8); 
            ekran_1_figure(52,14);
            ekran_1_figure(ds_ar[j],19); 
            if (BUT_OK) { if(++ds_ar[j]>8){ds_ar[j]=0;}    ochistka(); }
            if (BUT_STEP)   {  meny=91; z=0; z1=0; ochistka();}
        break;
        }                                                   
        
    //отсчет времени для включения освещения
	if(timerLight>0 && time<sunriseToday && time>sunsetToday && historyTemp[4]>tempMin )       //закат восход + температура бани превышающая минимум
		PORTC.2=1;
	else{
		endSwitch=0;
		PORTC.2=0;
	}
    
         
//****************************************************Сюда заходим каждую минуту*******************************************        
if (flg_min){  
    sunrise_update();    
    flg_min=0;
        //_____________________включение будильников
        for (bud_temp=0; bud_temp<9; bud_temp++)  
        {  
                if  (  
                    ( time==budilnik_time[bud_temp] )                                 //  если наступило время срабатывания будильника
                &&  ( budilnik_Install[bud_temp] & 0x80)                              //  И этот будильник включен (должен срабатывать)
                &&  ( budilnik_Install[bud_temp] & (1 << den_nedeli) )                //  И должен сработать в текущий день недели   
                )                                                                                 
                bud_flg=1;                                                            //  то включить сигнал 
                
        //______________________ВЫключение будильников        
                if ( time==budilnik_time[bud_temp] +  budilnik_Interval[bud_temp])    //  если будильник "отзвенел" установленное время(от 1 до 15 мин)
                {
                bud_flg=0;                                                            //  то выключить сигнал
                if (bud_temp<3)  {budilnik_Install[bud_temp] = 0;}                    //  и если будильник "одноразовый" (№ 1-3), то выключаем его повторную сработку
                }
        }
        //______________________ежечасный сигнал         
        if ( (time%60==0)&&(time > 500)&&(zv_chs) ) {  but_flg=1; tone=5;   TIMSK|=0x10;    but_pause=0;  }    //  Писк каждый час (с 00-00 до 08-00 сигнал не срабатывает)    
}       ;
// включаем прерывание по совпадению "А" с Т1 (Пищим динамиком. Будильник) 
if ( ((bud_flg)&&(mig)) ||  (but_flg) )   { 
 tone=3; TIMSK|=0x10;
}    
else  {PORTB.5=0; TIMSK&=0xEF;} 
                              
	//Работа тревоги
	if(timerAlert>0 && mig && time > 500){
	 TIMSK|=0x10;     
	}
    //Добавь дрова
	if(timerDrova>0 && mig && time > 500 && noticeBanya){
	 TIMSK|=0x10;     
	}
    //Баня Готова
	if(completeBeepTime>0 && time > 500 && delayBan==0 && noticeBanya){ 
     tone=8;
	 TIMSK|=0x10;     
	}
    
//****************************************************************************************************************************  
while (POWER == OFF )   // если работаем от батареи, то сидим здесь и не вылазим - усыпляем контроллер
    {
    ACSR=0x80;          // выключаю компаратор и внутренний ИОН на время сна (для экономии энергии батарейки)
    #asm("sleep")       // спим......
    ACSR=0x4b;          // включаю компаратор, внутренний ИОН. 
    }
//****************************************************************************************************************************       
};
}
