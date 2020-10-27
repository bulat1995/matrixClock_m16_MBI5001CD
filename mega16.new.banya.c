#define GETBIT(data, index) ((data & (1 << index)) == 0 ? 0 : 1)

//_____________________________________НАСТРОЙКА КОМПИЛЯЦИИ____________________________________/
//_____________________________________________________________________________________________/
#define   VER               109       // версия прошивки
//_____________________________________________________________________________________________/
//поставьте единичку напротив примененного вами контроллера 
#define   ATMEGA16          1
//_____________________________________________________________________________________________/
//поставьте единичку напротив примененных вами индикаторов
#define   OA                1         // для матрицы с "ОА"  (на выводах 5, 2, 7, 1, 12, 8, 14, 9 аноды  диодов)  
//_____________________________________________________________________________________________/
//поставьте напротив FONT  номер желаемого шрифта цифр (от 0 до 6)
#define   FONT              5         // выбираем шрифт цифр
//_____________________________________________________________________________________________/
//поставьте единичку если нужно отображать температуру с десятыми долями градуса
#define   TENTH_HOUSE       1         // для температуры дома
#define   TENTH_STREET      1         // для температуры на улице
#define	  TENTH_BANYA		1			//Для температуры в бане
#define	  TENTH_WATER		1			//для температуры воды в бане
#define	  TENTH_PODVAL1		1			//Температура в подвале №1
#define	  TENTH_PODVAL2		1			//Температура в подвале №2
//_____________________________________________________________________________________________/



/***********************************************************************************************
Контроллер   -  ATmega16А/16L/32A/32L    (камень без буквы может не заработать от 3х вольтовой батарейки)
Частота чипа - 8,000000 MHz
**********************************************************************************************/
# if ATMEGA16
	#include <mega16.h>
# endif 
 
#include <1wire.h>
#include <ds18b20_.h>
#include <delay.h>


#define   BUT_OK      button==1
#define   BUT_STEP    button==2
#define	  BUT_BANYA     1
#define	  BANYA_SWITCH  1 //КОнцевик в бане
#define	  HOME_SWITCH   1 //КОнцевик дома

#define   POWER       power
#define   ON          1
#define   OFF         0
//*********************************************************************************************/

bit                 mig, flg_min=0, bud_flg=0, but_flg=0,  zv_kn=0,  zv_chs=1, but_on=0, line=0, power=1, temp5, flg_adch, flg_ds18b20,


	pumpStatus=0, /*Состояние выхода насоса*/,
	alertBanya=0,//Тревога нажата кнопка в бане
	banya_is_complete=0, //готова ли баня
	needDrova=0,//Нужны ли дрова 
	endSwitch[2]={0,0},/*Состояние концевиков в бане и на улице*/
	


;

int timeToComplete=0, //Время готовности бани в минутах
	sunrise[12]={0,-33,-62,-78,-69,-51,-2,43,57,54,51,57},//Восход
	sunriseStartTime=601, //Время восхода для начала расчета
	sunset[12]={0,52,60,61,57,53,14,-38,-69,-77,-73,-45}//Закат
	sunsetStartTime=1020, //Время заката для начала расчета 
	sunriseToday=0;//Время восхода сегодня
	sunsetToday=0;//Время заката сегодня

;
unsigned char       meny=10, sek=0, chislo=25, mesec=3, god=12, den_nedeli, bud_temp, button, but_pause=0,  z, z1, bud, temp, temp1=0, temp2=0, t, flg_korr=1, speed=28, foto_r=0,
                    str_sec=0,    
                    ekran            [24],         // Экранный  буфер
                    beg_info         [250],        // Бегущая строка в основном режиме 
                    rom_code         [2][9],       // масив с адресами найденых датчиков DS18B20
                    budilnik_Install [9],          // храним настройки будильников
                    budilnik_Interval[9];          // храним значение длительности сигнала будильника
unsigned   int      budilnik_time    [9];          // храним время сработки будильников
const unsigned char
        budilnik_txt         []= {11,29,14,18,21,38,23,18,20,42,255},       // текст "Будильник"
        korekt_txt           []= {20,24,26,26,15,20,32,18,41,42,42,255},    // текст "Коррекция"
        nastroiki_txt        []= {29,27,28,10,23,24,12,20,18,42,255},       // текст "Установки"
        den_txt              []= {14,15,23,38,255},                         // текст "День"
        data_txt             []= {14,10,28,10,255},                         // текст "Дата"
        god_txt              []= {13,24,14,255},                            // текст "Год"
        nastr_stroki_txt     []= {23,10,27,28,26,24,19,20,10,42,255},       // текст "Настройки"
        den_nedeli_txt  [7][12]= {{25,24,23,15,14,15,21,38,23,18,20,255},   // Понедельник     //  названия дней недели
                                 {12,28,24,26,23,18,20,255},                // Вторник         //
                                 {27,26,15,14,10,255},                      // Среда           //
                                 {33,15,28,12,15,26,13,255},                // Четверг         //
                                 {25,41,28,23,18,32,10,255},                // Пятница         //
                                 {27,29,11,11,24,28,10,255},                // Суббота         //
                                 {12,24,27,20,26,15,27,15,23,38,15,255}},   // Воскресенье     //                                    
        den_nedeli_letter[7][2]= {{25,23},                                  // Пн              //  сокращенные названия дней недели
                                 {12,28},                                   // Вт              //
                                 {27,26},                                   // Ср              //
                                 {33,28},                                   // Чт              //
                                 {25,28},                                   // Пт              //
                                 {27,11},                                   // Сб              //
                                 {12,27}},                                  // Вс              //            
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
                                 {14,15,20,10,11,26,41,255}}               // Декабря           
		banya_prognoz[23]={11,10,20,41,42,11,29,14,15,28,42,13,24,23,24,12,10,42,55,42,12,42,255}, /*Баня будет готова в */
        banya_add[22]={25,24,14,20,18,23,38,42,14,26,24,12,10,42,12,42,25,15,33,28,54,255}, /*Подкинь дрова в печь!*/ 
        pump_is_on[22]={12,20,21,40,33,15,23,42,29,21,18,33,23,37,19,42,23,10,27,24,27,255}/*Включен уличный насос*/                        
		;
flash  const unsigned char  simvol [][5]=     
    {
    # if FONT==0    //  Шрифт цифр №0
    { 0x3E, 0x51, 0x49, 0x45, 0x3E },  // 0
    { 0x00, 0x42, 0x7F, 0x40, 0x00 },  // 1
    { 0x42, 0x61, 0x51, 0x49, 0x46 },  // 2
    { 0x21, 0x41, 0x45, 0x4B, 0x31 },  // 3
    { 0x18, 0x14, 0x12, 0x7F, 0x10 },  // 4
    { 0x27, 0x45, 0x45, 0x45, 0x39 },  // 5
    { 0x3C, 0x4A, 0x49, 0x49, 0x30 },  // 6
    { 0x01, 0x71, 0x09, 0x05, 0x03 },  // 7
    { 0x36, 0x49, 0x49, 0x49, 0x36 },  // 8
    { 0x06, 0x49, 0x49, 0x29, 0x1E },  // 9
    # endif
    # if FONT==1    //  Шрифт цифр №1
    { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
    { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
    { 0x61, 0x71, 0x59, 0x4F, 0x47 },
    { 0x41, 0x49, 0x49, 0x7F, 0x7F },
    { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
    { 0x4F, 0x4F, 0x49, 0x79, 0x79 },
    { 0x7F, 0x7F, 0x49, 0x79, 0x79 },
    { 0x01, 0x71, 0x79, 0x0F, 0x07 },
    { 0x7F, 0x7F, 0x49, 0x7F, 0x7F },
    { 0x5F, 0x5F, 0x51, 0x7F, 0x7F },
    # endif
    # if FONT==2    //  Шрифт цифр №2
    { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
    { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
    { 0x63, 0x73, 0x59, 0x4F, 0x47 },
    { 0x63, 0x63, 0x49, 0x7F, 0x77 },
    { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
    { 0x6F, 0x6F, 0x49, 0x79, 0x79 },
    { 0x7F, 0x7F, 0x49, 0x7B, 0x7B },
    { 0x03, 0x73, 0x79, 0x0F, 0x07 },
    { 0x77, 0x7F, 0x49, 0x7F, 0x77 },
    { 0x6F, 0x6F, 0x49, 0x7F, 0x7F },
    # endif
    # if FONT==3    //  Шрифт цифр №3
    { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
    { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
    { 0x61, 0x71, 0x59, 0x4F, 0x47 },
    { 0x41, 0x49, 0x49, 0x7F, 0x7F },
    { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
    { 0x4F, 0x49, 0x49, 0x79, 0x79 },
    { 0x7F, 0x49, 0x49, 0x79, 0x79 },
    { 0x01, 0x01, 0x01, 0x7F, 0x7F },
    { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
    { 0x1F, 0x11, 0x11, 0x7F, 0x7F },
    # endif
    # if FONT==4    //  Шрифт цифр №4
    { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
    { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
    { 0x63, 0x71, 0x59, 0x4F, 0x47 },
    { 0x63, 0x41, 0x49, 0x7F, 0x7F },
    { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
    { 0x6F, 0x49, 0x49, 0x79, 0x79 },
    { 0x7F, 0x49, 0x49, 0x7B, 0x7B },
    { 0x03, 0x01, 0x01, 0x7F, 0x7F },
    { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
    { 0x1F, 0x11, 0x11, 0x7F, 0x7F },
    # endif
    # if FONT==5    //  Шрифт цифр №5    
    { 0x3E, 0x7F, 0x41, 0x7F, 0x3E },
    { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
    { 0x62, 0x73, 0x59, 0x4F, 0x46 },
    { 0x22, 0x63, 0x49, 0x7F, 0x36 },
    { 0x18, 0x14, 0x12, 0x7F, 0x7F },
    { 0x2F, 0x6F, 0x45, 0x7D, 0x39 },
    { 0x3E, 0x7F, 0x49, 0x7B, 0x32 },
    { 0x03, 0x73, 0x79, 0x0F, 0x07 },
    { 0x36, 0x7F, 0x49, 0x7F, 0x36 },
    { 0x2E, 0x6F, 0x49, 0x7F, 0x3E },
    # endif
    # if FONT==6    //  Шрифт цифр №6
    { 0x3E, 0x41, 0x41, 0x7F, 0x3E },
    { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
    { 0x62, 0x71, 0x59, 0x4F, 0x46 },
    { 0x22, 0x41, 0x49, 0x7F, 0x36 },
    { 0x18, 0x14, 0x12, 0x7F, 0x7F },
    { 0x2F, 0x45, 0x45, 0x7D, 0x39 },
    { 0x3E, 0x49, 0x49, 0x7B, 0x32 },
    { 0x03, 0x71, 0x79, 0x0F, 0x07 },
    { 0x36, 0x49, 0x49, 0x7F, 0x36 },
    { 0x26, 0x49, 0x49, 0x7F, 0x3E },
    # endif                    
    { 0x7C, 0x12, 0x12, 0x7C, 0xAA },  // А  10
    { 0x7E, 0x4A, 0x4A, 0x32, 0xAA },  // Б  11
    { 0x7E, 0x4A, 0x4A, 0x34, 0xAA },  // В  12
    { 0x7E, 0x02, 0x02, 0xAA, 0x00 },  // Г  13
    { 0x60, 0x3C, 0x22, 0x3E, 0x60 },  // Д  14
    { 0x7E, 0x4A, 0x4A, 0xAA, 0x00 },  // Е  15
    { 0x4A, 0x4A, 0x7E, 0xAA, 0x00 },  // З  16
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
    { 0xAA, 0xAA, 0xAA, 0xAA, 0x00 },  // маленький пробел    44
    { 0x00, 0x00, 0x00, 0x00, 0x00 },  // "полный" пробел     45
    { 0x08, 0x08, 0x08, 0x08, 0x08 },  // минус               46
    { 0x08, 0x08, 0x3E, 0x08, 0x08 },  // плюс                47
    { 0x06, 0x09, 0x09, 0x06, 0xAA },  // знак градуса        48
    { 0x3E, 0x41, 0x41, 0x41, 0x22 },  // большая C           49
    { 0x04, 0x3F, 0x44, 0x20, 0xAA },  // прописная t         50
    { 0x08, 0x08, 0x08, 0xAA, 0x00 },  // маленький минус     51
    { 0x3F, 0x40, 0x40, 0x3f, 0x00 },  // заглавная  V        52
    { 0x40, 0x40, 0x40, 0xAA, 0x00 },  // подчеркивание _     53
    { 0x00, 0x5F, 0xAA, 0x00, 0x00 },  // восклиц знак        54
    { 0x24, 0x48, 0x48, 0x24, 0x48 },  // знак примерно        55
    { 0x00, 0x24, 0x00, 0x00, 0x00 },  // двоеточие        56
    },
    
  
dnei_v_mesc     []= {31,29,31,30,31,30,31,31,30,31,30,31};           // Количества дней по месяцам 
unsigned   int          time=720 , Interval , Interval_2, data1, str_time=0
						lightTime=120/*Время освещения в секундах */,
						timerLight=0,/*Время отчитываемое в системе на освещение*/,
						alertTime=3, // Время работы тревожного сигнала из бани в секундах
						timerAlert=0, // отсчитываемое время  тревожного сигнала из бани в секундах

	;
						
float                   temperature_temp;
eeprom signed int       korr_den=0, brigh_up_time=360, brigh_down_time=1380;
eeprom unsigned char    brigh_up=9, str_period=61,  str=0x1B; //0x18;
static  signed   int    temperature [12]={10,20,30,40,50,60,70,80,90,100,110,120}; 

double historyTemp[5]={-100,-100,-100,-100,-100}; //История градусов в бане для прогноза 

eeprom  char ds1820_d=0, ds1820_y=1;
 unsigned char devices=0;

//___________________________Возвращает абсолютное значение числа_____________________________________ 
signed int abs (signed int x)
{
if (x<0) x=(x*(-1));
return x;
}

//______вычислить день недели по дате(спасибо форумчанину DANKO c сайта "радиокот"за формулу  )_________
unsigned char Day_week (void) 
{
unsigned char y, m, myday;

   y = god;
   m = mesec;

   if (m > 2) { m -= 2;       }
   else       { m += 10; y--; }

   myday = ((chislo + y + (y>>2) + ((31 * m) / 12)) % 7);
   
   if (myday)  return myday-1;  else  return  6;
}

//___________________________________________коррекция времени___________________________________________
void correkt (void)
{   
        if(korr_den<0) {TCNT2=255+((korr_den%10)*25); sek=59+((korr_den%600)/10); if (sek==60) {sek=0;} time=1439;}    
        else {TCNT2=25*(korr_den%10); sek=((korr_den%600)/10);} 
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
        static unsigned char stroka=0, i=0; 
        static unsigned int pumpPause=0;
        bit pumpButtonClick=0;

        //***********меряем освещенность***************************
        if(flg_adch)                    // один раз в секунду заходим сюда чтоб померить напряжение на фоторезисторе
        {
        flg_adch=0;                     // сбрасываем "ежесекундный"  флаг
        PORTA.7=0; DDRA.7=0;            // вывод РА.7  делаю входом, для того чтоб использовать его в качестве входа АЦП, 
        ADCSRA=0b11000011;              // запускаю АЦП (меряем напряжение на фоторезисторе)
        while (ADCSRA&0b01000000){}     // ждём когда АЦП закончит преобразование
        DDRA.7=1;                       // вывод РА.7  делаю выходом
        }
        //***********************************************************        
        stroka++;  
        if (stroka==8)  stroka=0; 
        PORTD.7=1;
        //включение напряжения на индикацию
        PORTD.6=1;
            ///Здесь должен быть построчный запуск матрицы
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
       	}
       	if(pump_pause>300 && !pumpButtonClick){
       		pump_pause=0;
       		pumpStatus!=pumpStatus; /*Смена состояния насоса*/
       		PORTD.1=pumpStatus; //Включение/отключение насоса
       	}
       	/*тревога*/
       	else if(!pumpButtonClick && pump_pause>0)
       	{
       		pump_pause=0;
       		timerAlert=alertTime;
       	}


       	//Если сработал концевик дома или в бане
       	if( (endSwitch[0]==1 || endSwitch[1]==1) && timerLight==0 ){
       		timerLight=lightTime;
       	}

       	//Если время истекло отключяем концевики
       	if(timerLight==0){
       		endSwitch[0]=0;
       		endSwitch[1]=0;
       	}
       	//Если концевики сработали ровно
       	if(endSwitch[0]=endSwitch[1] && timerLight!=0){
			timerLight=0;
       	}





        but_pause++;  if (but_pause==100)      { but_pause=0; but_on=1; }                 // если с момента прошлого нажатия кнопки прошло больше 0,3 сек - разрешаю очередное чтение кнопок
        if ((but_pause==30)&&(but_flg))        { but_flg=0; PORTB.5=0; TIMSK&=0xEF;}       // выключаю "писк" при нажатии кнопки      
        
        Interval++;   Interval_2++;                                                       //  отсчитываем интервал для бегущих строк и прочих нужд
}

//___________________________________Чтение состояния кнопок_______________________________________________
unsigned char  button_read (void)
{
    button=0;

    if ( (PIND.2==1 || PIND.4==1 || PINC.4==1 || PINC.5==1) && (but_on)){
        if(PIND.2==1){
            button=2;  
        }
        if(PIND.4==1){
            button=1;
        }

        //Концевик дома
       	if(PINC.4==1){
            endSwitch[0]=!endSwitch[0];
        }

        //Концевик улицы
       	if(PINC.5==1){
            endSwitch[1]=!endSwitch[1];
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

//______Прерывание от компаратора(заходим сюда когда пропадает и когда появляется внешнее напряжение)______
interrupt [ANA_COMP] void ana_comp_isr(void)               
{
        if(ACSR&0x20)                // если пропало внешнее питания
        {
        POWER = OFF;                 // переходим на резервное питание от батареек
        # if  ATMEGA16   
        MCUCR=0b01110000;            // разрешаем усыплять контроллер по команде SLEEP (для мега16)
        # endif
        # if  (ATMEGA32)  
        MCUCR=0b10110000;            // разрешаем усыплять контроллер по команде SLEEP (для мега32)
        # endif 
        TCCR0=0x00;                  // останавливаем Т/С0
        ADCSRA=0x00;                 // выключаю АЦП 
        TIMSK&=0x7f;                 // запрещаю прерывание по совпадению Т2
        ADMUX= 0b00100111;           // выключаю ИОН для АЦП
        PORTA=0;  DDRB=0b11110111;   // перевожу порты в состояние наменьшего потребления  
        PORTB=0; PORTC=0; PORTD=0;    
        }
        else                         // если  внешнее питания  появилось
        {
        //devices=w1_search(0xf0,rom_code);// если во время "сна" менялись/добавлялись датчики DS18B20,  то добавляем их в "систему"
        POWER = ON;                  // переходим на внешнее питание
        MCUCR=0b00110000;            // запрещаем усыплять контроллер по команде  SLEEP
        DDRB=0xE3;                   // возвращаем конфигурацию портов в рабочее состояние           
        TCCR0=0x03;                  // запускаем Т/С0
        ADCSRA=0b10000011;           // включаю АЦП 
        TIMSK|=0x80;                 // разрешаю прерывание по совпадению Т2
        ADMUX= 0b01100111;           // включаю ИОН для АЦП
        str_pause ();                // выщитываем время, следующего запуска бегущей строки
        }
}

//__________________________________________пищу динамиком__________________________________________________
interrupt [TIM1_COMPA] void timer1_compa_isr(void)
{
static char dl_1=0,dl_2=0;
dl_2++; if (dl_2>=150) {dl_2=0; dl_1++;  if (dl_1>=5) dl_1=0; }
if (but_flg) OCR1A=5;      //  если "пищим" по нажатию кнопки, или "ежечасно" то сигнал однотонный 
else  OCR1A = dl_1+3;      //  если "пищит" будильник, то сигнал "музыкальный"
PORTB ^= (1 << 5);
}

//____________________________управляем яркостью индикатора________________________________
interrupt [TIM2_COMP] void timer2_comp_isr(void)
{
if (foto_r)                           // если фоторезистор подключен
    {
    flg_adch=1;                       // разрешаем запустить АЦП
    if (ADCH > brigh_up*70/100)       // если "освещенность" больше 70% 
        {
        TIMSK&=0xFD;                  // индикаторы горят в полную силу (запрещаем прерывание по совпадению ТО ) 
        }
    else                              // если "освещенность" меньше 70%  
        {
        OCR0=ADCH;                    // пропорционально снижаем яркость индикатора.
        if (OCR0<20) OCR0=20;         // если полная темнота,  то не даём яркости экрана падать до 0
        TIMSK|=0x02;                  // разрешаем прерывание по совпадению Т0 
        }
    }
else                                  // если фоторезистор не используется
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
//_______________________________________________________________________________
flg_ds18b20=1; // попутно подымим флаг для разрешеия чтения датчиков температуры          
}



//____________________________________________отсчет времени________________________________________________
interrupt [TIM2_OVF] void timer2_ovf_isr(void)
{
	static bit aleOff=0;
	mig++; 
	sek++;     //  Инкреминируем секунды

	//Работа тревоги
	if(timerAlert>0){
		timerAlert--;
		TIMSK|=0x10;
		aleOff=1;
	}
	else if (aleOff){
		aleOff=0;
		TIMSK&=0xEF;
	}


if (sek==60) {






/*
	Добавить: Расчет температуры по времени года и датчикам 
			  по которым еобходимо читать температуру
			Пищалку для готовности бани и добавлении дров
*/

	for(int j=0;j<4;j++) {
		historyTemp[j]=historyTemp[j+1];
	}

	double arifMin=0;
	for(int j=0;j<4;j++) {
		arifMin+=(historyTemp[j+1]-historyTemp[j]);
	}
	arifMin/=4;
	historyTemp[4]=temperature[3];
	//Прогноз для бани
	if(temperature[3]<60 && temperature[3]>27 && !banya_is_complete){
		//Добавь дрова в печку
		if(arifMin>(historyTemp[4]-historyTemp[3])){
			needDrova=1;
		}
		//Готовность бани в минутах
		timeToComplete=(int)(60-historyTemp[4])/arifMin;
		banya_is_complete=0;
	}
	//Баня готова
	else if(temperature[3]>60){
		needDrova=0;
		banya_is_complete=1;
	}
	else
	{
		//обнуление истории бани
		for(int j=0;j<5;j++) {historyTemp[j]=-100;}
		banya_is_complete=0;
		needDrova=0;
	}









	sek=0; time++; flg_min=1; if (time==1440)
                { 
                if(flg_korr)  {correkt(); flg_korr=0;  if(korr_den<0) goto m2;}  //  в 00-00, если еще сегодня не проводилась коррекция - провести коррекцию.    
                time=0;  chislo++; if (chislo > dnei_v_mesc[mesec-1])
                        {chislo=1; mesec++; if (mesec==13)
                                {mesec=1; god++;
                                }
                        }
                if ( (god%4) && (mesec==2) && (chislo==29) )  {mesec=3; chislo=1;}      // если НЕвысокосный год, то 29.02>>>>>01.03
                flg_korr=1;
                m2:                                           
                }
        }


	/*
		Поправить температуру при выходе из дома
	*/
    //отсчет времени для освещения
	if(timerLight>0){
		if(time<sunriseToday && time>sunsetToday )
		{
			//Выход из бани
			if(endSwitch[0]==1 && endSwitch[1]==0){
				PORTC.2=1;
				if(lightTime-timerLight>10){
					PORTC.3=1;
				}
			}
			//Выход из дома
			if(endSwitch[0]==0 && endSwitch[1]==1){
				PORTC.3=1;
				if(lightTime-timerLight>10 && temperature[3]>27){
					PORTC.2=1;
				}
			}
		}
		timerLight--;
	}
	else{
		endSwitch[0]=0;
		endSwitch[1]=0;
		PORTC.2=0;
		PORTC.3=0;
	}


}

//Обновление восхода и заката 
void sunrise_update()
{
    sunriseToday=sunriseStartTime;
    sunsetToday=sunsetStartTime;
    for(int i=1;i<mesec;i++){
    	sunriseToday+=sunrise[i-1];
    	sunsetToday+=sunset[i-1];
    }
    sunriseToday+=(int)((sunrise[mesec-1]/dnei_v_mesc[mesec])*chislo);
    sunsetToday+=(int)((sunset[mesec-1]/dnei_v_mesc[mesec])*chislo);
}

//______________________загрузка в экранный буфер символов + мигающая точка в центре_________________________
 void ekran_cifri (unsigned  int data)
{  
    unsigned char           x,x1,x2,x3,y,y1,y2,y3,temp; 
    static unsigned char    Shift_zn;  

    
  x  =  ((data/600)==0)? 45: (data/600); 
x1 =  (data%600)/60;
x2 =  (data%60)/10;
x3 =  data%10;

y  =  ((data1/600)==0)? 45: (data1/600);
y1 =  (data1%600)/60;
y2 =  (data1%60)/10;
y3 =  data1%10;
    
  
if (data != data1)        //  если сменилась мнформация - запускаем скроллинг
{  
    if (Interval_2>40){Interval_2=0; Shift_zn++;  if(Shift_zn==8) {Shift_zn=0;data1=data;}   }
    {

    for (temp=0; temp<5; temp++)
    { 
    if(x !=y ) {ekran [temp   ] =  (   (simvol [y ][temp]<<Shift_zn)  +   (simvol [x ][temp]>>(8-Shift_zn))   );}   else  { ekran [temp   ]=(simvol [x ][temp]);  }
    if(x1!=y1) {ekran [temp+ 6] =  (   (simvol [y1][temp]<<Shift_zn)  +   (simvol [x1][temp]>>(8-Shift_zn))   );}   else  { ekran [temp+ 6]=(simvol [x1][temp]);  }
    if(x2!=y2) {ekran [temp+13] =  (   (simvol [y2][temp]<<Shift_zn)  +   (simvol [x2][temp]>>(8-Shift_zn))   );}   else  { ekran [temp+13]=(simvol [x2][temp]);  }
                ekran [temp+19] =  (   (simvol [y3][temp]<<Shift_zn)  +   (simvol [x3][temp]>>(8-Shift_zn))   );
    }
    }
}
else
{
    for (temp=0; temp<5; temp++)
    {                                                                                                    
    ekran [temp   ]=(simvol [x ][temp]);
    ekran [temp+ 6]=(simvol [x1][temp]);
    ekran [temp+13]=(simvol [x2][temp]);
    ekran [temp+19]=(simvol [x3][temp]);
    }
    Interval_2=0;
}
if (mig) {ekran [12]=0;  ekran [11]=128;}   // перемигивание точек в основном режиме.
else     {ekran [12]=128;  ekran [11]=0;}   //
}

//___________________________загрузка в отределенное место экрана 1 символа_________________________________
 void ekran_1_figure (unsigned char x,unsigned char x1,)          
{                                                                                                                         
   unsigned char temp;                                                          
   for (temp=0; temp<5; temp++)
   {
   if (simvol [x][temp]==0xAA) return;                                                                                                            
   ekran [temp+x1]=(simvol [x][temp])  +(128*mig*line);
   }
}

//_______________________________________Гасим весь экран__________________________________________________
void ochistka (void)
{
unsigned char temp;
for (temp=0;  temp<24; temp++) {ekran[temp]=0  ;}
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
unsigned char beg_stroka (unsigned char x[],)
{
  static unsigned char temp, counter=0, i;
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
 
//__________________________________вывод неподвижного текста_______________________________________________
void txt_ekran (unsigned char x[],)
{
unsigned char temp =0,  temp1=0, temp2=0;

    for(temp=0;temp<24;temp++)
    {
    if ((temp2==5) || (simvol[x[temp1]][temp2] == 0xAA)) {ekran[temp]=0;   temp2=0; temp1++;} else {ekran[temp]=simvol[x[temp1]][temp2]; temp2++;}
    if (x[temp1]==255) return ; //{temp=24;}
    }
}


//*****************************************************************************************************************//
//*****************************************************************************************************************//
//*****************************************************************************************************************//
//*****************************************************************************************************************//
void main(void)
{


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
#asm("sei")
//_______________________________________Отображаем номер версии прошивки___________________________________________
ochistka();    // Очищаем весь зкран
str_pause ();  // Вычисляем время запуска бег строки.

//*****************************************************************************************************************//
//*****************************************************************************************************************//
while (1)
{
//zv_chs=1;
button_read();   // Опрос кнопок

switch (meny)
        {
        case 10: //______основной режим 
                ekran_cifri(time);  // отображаем время      
                //______запуск бегущей строки        
                if ( ((sek >= str_sec) && (time == str_time))    &&  (str != 0) )   {meny=11 ;z=0; z1=0; temp2=str;}           // Запускаем бегущую строку                
                if (BUT_STEP) {meny=30; z=0; z1=0; ochistka();  bud_flg=0;data1=(((time-(time/60*60))*60)+sek);}
                if (BUT_OK)   {meny=11 ;z=0; z1=0; temp2=0x18;}                //   0x18;
        break;
        
        case 11: //______Формируем и вывожу бег строку.
                t=0; temp1=0;  den_nedeli=Day_week ();

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



                /*Отображение температуры в бане */
                if(temperature[3]>27){
					//  Баня вывод прогноза
                	if(timeToComplete<240 && timeToComplete>0){
	                	temp1=t;
                        while (banya_prognoz[(t-temp1)] != 255)      
						{     
                                beg_info[t]=banya_prognoz[t++-temp1];
                        } 
	                	int timeComplete=time+timeToComplete;
						beg_info[t++]=42;                                                    // пробел
						//составление прогноза готовности бани
		                beg_info[t++]=(timeComplete/600==0)?45:(timeComplete/600);             //    десятки часов
		                beg_info[t++]=(timeComplete%600)/60;         //    единицы часов
		                beg_info[t++]=44;                    		 //    разделительная точка
		                beg_info[t++]=(timeComplete%60)/10;          //    десятки минут
		                beg_info[t++]=timeComplete%10;               //    единицы минут
                	}

                	//Уведомление о необходимости добавления дров
                	if(needDrova)
                	{
                		temp1=t;
                        while (banya_add[(t-temp1)] != 255)      
						{     
                            beg_info[t]=banya_add[t++-temp1];
                        } 
                	}

                	//Температура в бане
					beg_info[t++]=42;                                                    // пробел
                    if ((temp2 & 0x10) && (devices>1)) {beg_info[t++]=11;  beg_info[t++]=10;  beg_info[t++]=23;beg_info[t++]=41; beg_info[t++]=56; beg_info[t++]=42;}    // слово "Баня"  
                    if (temperature[ds1820_d]<0) beg_info[t++]=51;  else beg_info[t++]=47;              // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
                    if (abs(temperature[ds1820_d])>99) {beg_info[t++]=(abs(temperature[ds1820_d])/100);}// Если темп >10,  выводим "десятки" температуры дома
                    beg_info[t++]=(abs(temperature[ds1820_d])%100)/10;                   // Выводим "единицы температуры"
                    # if TENTH_HOUSE     // если дом. температура нужна с десятыми
                        beg_info[t++]=43;                                                // Разделительная точка
                        beg_info[t++]=abs(temperature[ds1820_d])%10;                     // Десятые доли градуса.
                    # endif
                    beg_info[t++]=48;                                                    // Знак градуса     
                    beg_info[t++]=44;                                                    // мал пробел
                    beg_info[t++]=42;  


                    //Температура воды в бане
					beg_info[t++]=42;                                                    // пробел
                    if ((temp2 & 0x10) && (devices>1)) {beg_info[t++]=12;  beg_info[t++]=24;  beg_info[t++]=14;  beg_info[t++]=10;beg_info[t++]=56;beg_info[t++]=42;}    // слово "Вода"  
                    if (temperature[ds1820_d]<0) beg_info[t++]=51;  else beg_info[t++]=47;              // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
                    if (abs(temperature[ds1820_d])>99) {beg_info[t++]=(abs(temperature[ds1820_d])/100);}// Если темп >10,  выводим "десятки" температуры дома
                    beg_info[t++]=(abs(temperature[ds1820_d])%100)/10;                   // Выводим "единицы температуры"
                    # if TENTH_HOUSE     // если дом. температура нужна с десятыми
                        beg_info[t++]=43;                                                // Разделительная точка
                        beg_info[t++]=abs(temperature[ds1820_d])%10;                     // Десятые доли градуса.
                    # endif
                    beg_info[t++]=48;                                                    // Знак градуса     
                    beg_info[t++]=44;                                                    // мал пробел
                    beg_info[t++]=42;  
                }




                if (  (temp2 & 0x08) && (devices>0) )                                        //  Если "Температура в доме" нужно выводить
                        {
                        beg_info[t++]=42;                                                    // пробел
                        if (temperature[ds1820_d]<0) beg_info[t++]=51;  else beg_info[t++]=47;              // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
                        if (abs(temperature[ds1820_d])>99) {beg_info[t++]=(abs(temperature[ds1820_d])/100);}// Если темп >10,  выводим "десятки" температуры дома
                        beg_info[t++]=(abs(temperature[ds1820_d])%100)/10;                   // Выводим "единицы температуры"
                        # if TENTH_HOUSE     // если дом. температура нужна с десятыми
                            beg_info[t++]=43;                                                // Разделительная точка
                            beg_info[t++]=abs(temperature[ds1820_d])%10;                     // Десятые доли градуса.
                        # endif
                        beg_info[t++]=48;                                                    // Знак градуса     
                        beg_info[t++]=44;                                                    // мал пробел
                        if ((temp2 & 0x10) && (devices>1)) {beg_info[t++]=14;  beg_info[t++]=24;  beg_info[t++]=22;  beg_info[t++]=42;}    // слово "ДОМ"  
                        beg_info[t++]=42;                                                    // пробел
                        }    


                if ( (temp2 & 0x10) && (devices>1) )                                         //  Если "Температура на улице" нужно выводить
                {
                        beg_info[t++]=29;  beg_info[t++]=21;                                 // слово  "УЛ"
                        beg_info[t++]=18;  beg_info[t++]=32;  beg_info[t++]=10;              // слово  "ИЦА"

                        if (temperature[ds1820_y]<0) beg_info[t++]=51;     else beg_info[t++]=47;          // если темп меньше уля - пишем знак минус   
                        if (abs(temperature[ds1820_y])>99){beg_info[t++]=(abs(temperature[ds1820_y])/100);}// Если модуль температуры >10,  выводим "десятки" температуры дома
                        beg_info[t++]=(abs(temperature[ds1820_y])%100)/10;                                 // Выводим "единицы температуры"    
                        # if TENTH_STREET    // если температура на улице нужна с десятыми
                            beg_info[t++]=43;                                                // Разделительная точка
                            beg_info[t++]=abs(temperature[ds1820_y])%10;                     // Десятые доли градуса.                        
                        # endif
                        
                        beg_info[t++]=48;                                                    // Знак градуса  
                        beg_info[t++]=42;                                                    // мал пробел
                        beg_info[t++]=42;  beg_info[t++]=42;                                 // пробел 
                }

                        
                        /*
                        for (temp1=2;temp1<devices+1;temp1++)                                         // если датчиков температуры больше 2х
                        {
                        beg_info[t++]=42;                                                             // пробел
                        if (temperature[temp1]<0) beg_info[t++]=51;  else beg_info[t++]=47;           // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
                        if (abs(temperature[temp1])>99) {beg_info[t++]=(abs(temperature[temp1])/100);}// Если темп >10,  выводим "десятки" температуры 
                        beg_info[t++]=(abs(temperature[temp1])%100)/10;                               // Выводим "единицы температуры"
                        // если температура  нужна с десятыми - раскомментируйте две строки ниже
                        // beg_info[t++]=43;                                                          // Разделительная точка
                        // beg_info[t++]=abs(temperature[temp1])%10;                                  // Десятые доли градуса.
                        beg_info[t++]=48;                                                             // Знак градуса     
                        beg_info[t++]=42;        //пробел
                        beg_info[t++]=50;        //буква "t"
                        beg_info[t++]=temp1+1;   //номер датчика
                        
                        beg_info[t++]=42;  beg_info[t++]=42; beg_info[t++]=42;                        // три пробела
                        } 
                        */     


                //вывод времени восхода
                beg_info[t++]=42;
                beg_info[t++]=12;beg_info[t++]=24;beg_info[t++]=27;
                beg_info[t++]=31;beg_info[t++]=24;beg_info[t++]=14;beg_info[t++]=56;

                beg_info[t++]=(sunriseToday/600==0)?45:(sunriseToday/600);             //    десятки часов
                beg_info[t++]=(sunriseToday%600)/60;         //    единицы часов
                beg_info[t++]=44;                    //    разделительная точка
                beg_info[t++]=(sunriseToday%60)/10;          //    десятки минут
                beg_info[t++]=sunriseToday%10;               //    единицы минут
                                         
                

                //вывод времени заката
                beg_info[t++]=42;
                beg_info[t++]=16;beg_info[t++]=10;beg_info[t++]=20;
                beg_info[t++]=10;beg_info[t++]=28;beg_info[t++]=56;
                beg_info[t++]=(sunsetToday/600==0)?45:(sunsetToday/600);             //    десятки часов
                beg_info[t++]=(sunsetToday%600)/60;         //    единицы часов
                beg_info[t++]=44;                    //    разделительная точка
                beg_info[t++]=(sunsetToday%60)/10;          //    десятки минут
                beg_info[t++]=sunsetToday%10;               //    единицы минут
                beg_info[t++]=43;

                
                beg_info[t++]=42;
                beg_info[t++]=(time/600==0)?45:(time/600);             //    десятки часов
                beg_info[t++]=(time%600)/60;         //    единицы часов
                beg_info[t++]=44;                    //    разделительная точка
                beg_info[t++]=(time%60)/10;          //    десятки минут
                beg_info[t++]=time%10;               //    единицы минут
                beg_info[t]=255;                     //    метка конца "бегущей строки"
                

                if (Interval >= speed){
                    Interval=0; 
                    if (beg_stroka(beg_info)==255){
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
        //*******Настройка бег строки. Выбираем какую информацию будем выводить с помощью бег. строки********** 
        case 50: // на экране текст - "Коррекция"
               if (Interval>=speed)  {Interval=0;   beg_stroka(nastr_stroki_txt);} 
               if (BUT_STEP) {meny=80; z=0; z1=0; ochistka();}
               if (BUT_OK)   {meny=51; ochistka(); temp=0;}
        break;
        case 51:
                if (BUT_STEP) {temp++; ochistka();}
                switch (temp)
                        {
                        case 0:  if (BUT_OK){str ^= (1 << 0);}   ekran_1_figure (((str & 0x01) ? 47:46),19);   txt_ekran(den_txt);            break;
                        case 1:  if (BUT_OK){str ^= (1 << 1);}   ekran_1_figure (((str & 0x02) ? 47:46),19);   txt_ekran(data_txt);           break; 
                        case 2:  if (BUT_OK){str ^= (1 << 2);}   ekran_1_figure (((str & 0x04) ? 47:46),19);   txt_ekran(god_txt);            break; 
                        case 3:  if (BUT_OK){str ^= (1 << 3);}   ekran_1_figure (((str & 0x08) ? 47:46),19);   ekran_1_figure(50,0); ekran_1_figure(48,4); ekran_1_figure(14,10);  break;
                        case 4:  if (BUT_OK){str ^= (1 << 4);}   ekran_1_figure (((str & 0x10) ? 47:46),19);   ekran_1_figure(50,0); ekran_1_figure(48,4); ekran_1_figure(29,10);  break;
                        case 5:  if (BUT_OK){zv_chs++;       }   ekran_1_figure (((zv_chs) ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(33,9); ekran_1_figure(27,14); break;
                        case 6:  if (BUT_OK){zv_kn++;        }   ekran_1_figure (((zv_kn)  ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(20,9); ekran_1_figure(23,14); break;
                        case 7:  meny=52; temp=speed; break;
                        }
        break;
        case 52: // настройка скорости бегущей строки
            if (Interval>=temp)  {Interval=0;   beg_stroka(beg_info);} 
            if (BUT_OK)  {temp+=3;  if (temp>=60) {temp=9;}}
            if (BUT_STEP)   {speed=temp;  if (devices==2){meny=53;temp5=0;}  else {if(foto_r)meny=56; else meny=54;} ochistka();}// если датчиков температы два, то переходим к их переназначению.
                                                                                                                        // если датчик один,  или вовсе отсутствует то переходим к настройке работы регулятора яркости экрана.
        break;                                                                                                          
        case 53: //  переназначение датчиков ds18m20 (если подключено 2 датчика)
            ekran_1_figure (14,0); 
            ekran_1_figure (((temperature[temp5]<0) ? 51:47),8);
            ekran_1_figure ((abs(temperature[temp5])/100),13);
            ekran_1_figure (((abs(temperature[temp5])%100)/10),19);
            if (BUT_OK)  {temp5++;}
            if (BUT_STEP)   { if(foto_r){meny=56;}else meny=54; if (temp5)  {ds1820_d=1; ds1820_y=0;}  else {ds1820_d=0; ds1820_y=1;} ochistka(); } 
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
        case 56: // Калибровка фоторезистора 
            ekran_1_figure(ADCH/100,3);  
            ekran_1_figure((ADCH/10)%10,9);
            ekran_1_figure(ADCH%10,15);
            if (BUT_OK)  {brigh_up=ADCH;}  // записываем значение АЦП при максимальной освещенности в переменную brigh_up
            if (BUT_STEP)   {meny=57; ochistka();} 
        break;
        case 57: // Настройка периода запуска  бегущей строки
        temp=str_period;
        ekran_1_figure( (temp%60)/10,13);          ekran_1_figure((temp%60)%10,19);
        temp=60*(ystanovki_2 (temp/60,3,0) );
        ekran_1_figure(0,0);          ekran_1_figure(temp/60,6);
        temp=temp+(ystanovki_2 (str_period%60,59,13));
        str_period=temp;
        str_pause ();  meny=10;
        break;
        //**************************Настройка коррекции хода*******************************
        case 80: // на экране текст - "Коррекция"
            if (Interval>=speed)  {Interval=0;   beg_stroka(korekt_txt);} 
            if (BUT_STEP) {str_pause ();  meny=10; ochistka();}
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
        }
      
        
//****************************************************Сюда заходим каждую минуту*******************************************        
if (flg_min)   
{
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
        if ( (time%60==0)&&(time > 500)&&(zv_chs) ) {  but_flg=1;   TIMSK|=0x10;    but_pause=0;  sunrise_update();}    //  Писк каждый час (с 00-00 до 08-00 сигнал не срабатывает)    
}       //but_flg=1;   TIMSK|=0x10;    but_pause=0;

if ( ((bud_flg)&&(mig))  ||  (but_flg) )   { TIMSK|=0x10;}    // включаем прерывание по совпадению "А" с Т1 (Пищим динамиком. Будильник) 
else  {PORTB.5=0; TIMSK&=0xEF;}                               



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
