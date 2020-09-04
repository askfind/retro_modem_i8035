```

         ╔═════════════════════════════════════════════════════╗
         ║   Реализация HAYES-системы команд для модема  V.23  ║
         ╚═════════════════════════════════════════════════════╝


        Ниже приведены реализованные команды. Команды должны состоять
        из заглавных букв латинского алфавита. Все команды (кроме A/)
        должны содержать в начале префикс AT который служит для обозна-
        чения начала новой командной строки. Командная строка должна
        заканчиваться кодом <CR>. В командной строке может подаваться
        как одна, так и несколько комманд. Все пробелы в командной строке
        игнорируются. Если в командной строке встречается символ <BS>, то
        предыдущий символ считается недействительным и игнорируется.
        Длина командной строки не должна превышать 90 символов.

  A/    Команда модему повторить предыдущую командную строку.
        Подается как есть без префикса AT и окончания строки <CR>.

  En    Управление эхом модема. После команды E1 модем возвращает каждый
        символ передаваемый ему по интерфейсу RS-232c в виде локального
        эха. E0 - блокировка локального эха.
        n=0             эхо выключено
        n=1             эхо включено
        n<>0 or 1       любой другой символ вызывает ошибку.

  Qn    Управление ответом модема. После получения команды Q0 модем дает
        ответ на полученную командную строку OK, в случае успешного выпол-
        нения, и ERROR в случае ошибки. После команды Q1 модем никаких
        ответов по завершении команды не дает.
        n=0             ответ включен
        n=1             ответ выключен
        n<>0 or 1       любой другой символ вызывает ошибку.

  Vn    Выбор вида ответа модема.
        n=0             ответ цифровым кодом
        n=1             ответ в символьном виде на английском языке
        n<>0 or 1       любой другой символ вызывает ошибку.

  Z     Восстановление начальных значений S-регистров из ППЗУ и установка
        тех режимов, которые были после включения питания модема.

  Srrr?
        Считывание содержимого S-регистра номер rrr. Номер задается деся-
        тичным числом и не должен превышать 255. Номер может задаваться
        без нулей слева либо с нулями, при этом общее число символов не
        должно превышать трех. В ответ на эту команду выдается три ASCII
        символа, которые представляют собой содержимое S-регистра в десяти-
        чном виде.

  Srrr=nnn
        Ввод числового параметра nnn в S-регистр номер rrr. Ограничения
        накладываемые на числа nnn и rrr такие же, как и в предыдущей
        команде. Все команды изменяют содержимое тех или иных S-регистров.
        Некоторые параметры можно поменять только командой S.

  Yn    Способ окончания процедуры ввода информации из телефонной линии.
        n=0     модем отключается после отключения компьютером сигнала DTR.
        n=1     модем отключается после перерыва в несущей частоте удален-
                ного модема дольше определенного промежутка времени.

  Hn    Управление линией.
        n=0     отключение модема от линии (модем кладет трубку)
        n=1     подключение модема к линии (модем берет трубку)

  I     Получив эту команду модем отвечает на нее текстовым сообщением
        которое содержит номер версии программы зашитой в ППЗУ.

  A     После этой команды модем начинает ввод информации из телефонной
        линии. Этапы выполнения команды следующие:

        1)    Подача собственной несущей частоты.

        2)    Поиск несущей частоты удаленного модема.
              Поиск несущей производится столько времени, сколько указа-
              но в регистре S7 (одна единица = 1 сек). В случае отсутствия
              несущей по истечении этого времени модем выдает ответ
              "NO CARRIER" и возвращается в командный режим.

        3)    В случае удачного поиска несущей частоты модем отвечает
              "CONNECT" , "CONNECT 1200" или "CONNECT 75" (в зависимости
              от выбора режима X0-X3)  и после получения информации из
              линии передает эту информацию по интерфейсу RS-232c.





        4)    Выход из режима приема в командный режим может осуществляться
              двумя способами (в зависимости от состояния Y0 или Y1).
              В состоянии Y0 выход происходит после того, как сигнал DTR
              содержится в неактивном состоянии дольше времени указанного
              в регистре S25 (одна единица = 0.02 сек).
              В состоянии Y1 выход происходит после того, как на линии
              дольше времени указанного в регистре S09 отсутствует несущая
              частота удаленного модема.

        5)    При выходе  в  командный режим  ( в зависимости от заданной
              комманды &Dn) могут выполняться действия по окончании связи,
              прекращении режима автоответа и инициализации S-регистров.


  O     После этой команды модем настраивается на режим передачи данных и
        отвечает CONNECT. Далее вся информация получаемая по интерфейсу
        RS-232c передается в телефонную линию.
        Если на интерфейсе RS-232c идет пауза дольше времени указанного в
        регистре S12 (одна единица регистра = 0.02 сек), а затем переда-
        ется последовательность из трех символов возврата "+++" , после
        чего опять следует пауза в передаче, модем переходит обратно в
        командный режим.
        (После чего можно закончить связь путем подачи команды AT H0).
        Символ, который модем воспринимает как символ возврата, содержится
        в регистре S2.

  Fn    Выбор скорости работы модема.
      n=0 - 1200 бит/сек прием, 75   бит/сек передача, стандарт V.23 mode 3
      n=1 - 600  бит/сек прием, 75   бит/сек передача, стандарт V.23 mode 3
      n=2 - 300  бит/сек прием, 300  бит/сек передача, стандарт V.21
      n=3 - 200  бит/сек прием, 200  бит/сек передача, стандарт V.21
      n=4 - 75   бит/сек прием, 1200 бит/сек передача, стандарт V.23 mode 4
      n=5 - 75   бит/сек прием, 600  бит/сек передача, стандарт V.23 mode 4

  Bn    Выбор стандартных частот работы.
        n=0 - работа в стандартах частот     V.23 (1200 бит/сек)
                                             V.21 (300 бит/сек)
        n=1 - работа в стандартах частот     BELL-202 (1800 бит/сек)
                                             BELL-103 (300 бит/сек)

  Mn    Управление динамиком (громкоговорителем) модема.
        n=0     Динамик выключен все время.
        n=1     Динамик включен только во время набора номера и выключается
                после обнаружения несущей.
        n=2     Динамик включен все время.
        n=3     Динамик включается после набора последней цифры номера и
                выключается после того, как модем обнаруживает несущую.

  Ln    Управление громкостью сигнала встроенного динамика.
        (Если модем оборудован ручным регулятором громкости, эта
        команда не работает).
        n=0,1   низкая
        n=2     средняя
        n=3     высокая

  Xn    Выбор вида процедуры набора номера и ответа после набора номера.
        n=0
        n=1
        n=2
        n=3
        n=4                             X0      X1     X2     X3     X4
        ________________________________________________________________

        Сообщение о связи                1       2      2      2      2
        Опоздание  (S6 сек)             да      да     нет    да     нет
        Ожидание сигнала коммутатора    нет     нет    да     нет    да
        Определение сигнала "занято"    нет     нет    нет    да     да

  Сообщение о связи 1   -  обозначает, что модем после установления связи
                           сообщит CONNECT, независимо от скорости работы.
  Сообщение о связи 2   -  обозначает, что модем после установления связи
                           сообщит следующий ответ в зависимости от ско-
                           рости работы: CONNECT 75 или CONNECT 1200.
  Опоздание (S6 сек)    -  обозначает, что модем перед набором телефонного
                           номера, ожидает определенное в S-регистре S6
                           время.
  Ожидание сигнала      -  обозначает, что модем будет ожидать сигнала
  коммутатора              станции 10 с, и если за это время сигнал не бу-
                           дет получен, то модем выдаст на интерфейс сооб-
                           щение  NO DIALTONE  и перейдет в командный ре-
                           жим работы.
  Определение сигнала   -  обозначает, что модем в случае занятости
  "занято" номера          вызываемого номера, выдаст сообщение BUSY
                           и возвратится в командный режим работы.




  Ds    Автоматический набор номера.
        После получения этой команды модем снимает трубку и начинает набор
        номера. После получениия связи (если не было специального параметра)
        модем переходит в режим передачи данных (как в команде AT O). Набор
        номера ведется в импульсном режиме (импульсами простоянного тока).
        Команда состоит из телефонного номера, в состав которого могут
        входить следующие управляющие параметры:

        s = ,   Обозначает перерыв перед набором следующей цифры S8 сек.

        s = ;   Применяется как последний знак в командной строке. Модем
                после выполнения процедуры набора номера переходит в команд-
                ный режим работы.

        s = @   Модем ожидает 5-секундной тишины на линии, если она
                не появляется в течении 30 сек. (содержимое регистра S7),
                модем отключается и отвечает NO ANSWER.
        s = !   Этот параметр ставится перед знаками последовательности набо-
                ра.  Получив этот  символ  модем кладет трубку  на 0.5 сек,
                затем снова снимает ее, и продолжает набор номера.
        s = S   Модем набирает телефонный номер из памяти (см. команду AT &Z)

        s = R   Записывается как последний символ в командной строке.
                Устанавливает модем после получения связи на частоты
                приема информации из телефонной линии.

        s = W   После получения этого символа модем ожидает 10 с  ответ стан-
                ции (длинный гудок) перед дальнейшим набором номера (например
                выход на автоматическую междугородную связь). Если модем не
                получает длинного гудка, он отключается от линии и выдает
                сообщение BUSY.

        Номер телефона сообщаемый модему может содержать любые вспомогательные
        символы (например < > - : # () $ * % ...) для облегчения работы опера-
        тора.

               ┌─────────────────────────────┐
               │Дополнительные HAYES-команды.│
               └─────────────────────────────┘

  &Cn   Функция сигнала DCD.
        n=0     Сигнал DCD активизируется с момента, когда модем первый раз
                определит наличие несущей. Далее сигнал DCD остается актив-
                ным на все время.
        n=1     Сигнал DCD существует с момента, когда модем определит нали-
                чие несущей. После окончания связи сигнал DCD сбрасывается.

  &Dn   Действия выполняемые модемом по окончании приема информации из
        телефонной линии.
        n=0     Модем вешает трубку и возвращается в командный режим.
        n=1     Модем просто переходит в командный режим.
        n=2     Модем вешает трубку, выключает функцию "auto-answer" и
                переходит в командный режим работы.
        n=3     Модем автоматически реализует команду ATZ и переходит в
                командный режим работы.

  &Z    Запись телефонного номера в память модема.
        (Максимум 90 знаков на номер, включая вспомогательные знаки)
        Пример: AT &Z (8W) 222-33-44<CR>

  &I    Выдача дополнительной информации о версии программного обес-
        печения и авторах разработки.

                 ┌─────────────────────┐
                 │  Функция автоответа │
                 └─────────────────────┘

           Если содержимое S-регистра S0 не равно 0, то модем находится в
        состоянии автоответа. Состояние автоответа означает, что модем сам
        будет регистрировать и отвечать на телефонные звонки. Если S0=4, то
        после 4-го звонка зарегистрированного модемом он снимет трубку и
        перейдет в режим ввода информации из линии (выполнению команды ATA).
        Если после первого звонка не следует следующий , то спустя 8 секунд
        счетчик звонков сбрасывается. Регистрация звонков в линии происходит
        одновременно с получением команд по интерфейсу RS-232c, поэтому
        у оператора всегда есть возможность вмешаться в этот процесс до
        момента когда модем снимет трубку. Если модем непосредственно перед
        наступлением  момента  ответа  принял  часть  команды  по интерфейсу
        RS-232c и не успел начать ее выполнение, то вся эта командная строка
        игнорируется, и модем продолжает выполнение со следующей команды
        после завершения процесса ввода информации.



                    ┌──────────────────────────────────────┐
                    │ Описание основных S-регистров модема │
                    └──────────────────────────────────────┘

        Диапазон числовых параметров находящихся в S-регистрах находится
        в пределах 0-255 (для некоторых параметров 1-255).
        "Величина" - обозначает значение параметра, которое закладывается
        в регистр после включения питания модема.

  S0  - Количество сигналов звонка, которого ждет модем перед ответом на
        вызов телефонной линии. S0=00 - автоответ выключен, S0>0 - включен
        Величина: 000

  S1  - Счетчик сигналов звонка (информационный параметр). Содержимое ре-
        гистра увеличивается каждый раз, когда модем получает сигнал звонка
        из телефонной линии. Если функция автоответа активизирована, то при
        выполнении ее счетчик сбрасывается. Если функция автоответа не акти-
        визирована, то содержимое счетчика сбрасывается по истечении 8 сек.
        после регистрации последнего звонка. Этот регистр - единственный,
        исполняющий чисто информационную роль, его содержимое доступно толь-
        ко для чтения.

  S2  - Символ возврата. Содержит десятичный код ASCII, который является зна-
        ком последовательности возврата /см. "+++"/
        Величина: 043 (ASCII "+")

  S3  - Символ <CR>. Содержит десятичный код символа ASCII, который является
        знаком <CR>.
        Величина: 013 (ASCII "<CR>" или Ctrl-M)

  S4  - Символ <LF>. Содержит десятичный код символа ASCII, который является
        знаком новой строки <LF>.
        Величина: 010 (ASCII "<LF>" или Ctrl-J)

  S5  - Символ <BS>. Содержит десятичный код символа ASCII, который является
        знаком "забой".
        Величина: 008 (ASCII "<BS>" или Ctrl-H)

  S6  - Время ожижания заявления станции. (Задержка перед подачей своей несу-
        щей после снятия трубки).
        Величина: 002 сек.

  S7  - Время ожидания сигнала несущей.
        Величина: 030 сек.

  S8  - Время интервала (паузы) при наборе.
        Величина: 002 сек.

  S9  - Время реакции DCD. Время задержки активизации сигнала DCD вследствие
        появления несущей и задержки определения пропадания несущей.
        Величина: 0.5 сек. (одна единица регистра равна 0.1 сек)

  S10 - Задержка раз'единения после потери несущей.
        Величина: 1.4 сек (одна единица регистра равна 0.1 сек).

  S11 - Минимальная задержка передачи информации после выдачи несущей
        Величина: 1.2 сек (одна единица регистра равна 0.1 сек)

  S12 - Время требуемой тишины для последовательности возврата.
        Величина: 1.0 сек (одна единица регистра равна 0.02 сек).

  S13 - Число стоп бит посылаемого в телефонную линию байта. Число посыла-
        емых стоп бит на единицу больше содержимого регистра.
        Величина: 00 (один стоп бит)

  S14 - Признак наличия тестовой петли эха при работе модема. Если содержи-
        мое регистра равно 00, то петля отсутствует. Если содержимое равно
        01, то информация передаваемая по интерфейсу RS-232c во время сеанса
        связи возвращается на интерфейс RS-232c в виде эха.
        Величина: 00

  S15 - Время ожидания сигнала готовности станции (длинного гудка) во время
        операции набора номера. Время ожидания исчисляется как
        (10 сек. + N*1 сек.) , где N - содержимое регистра.
        Величина: 10 сек

  S25 - Время после которого модем обнаруживает потерю сигнала DTR для окон-
        чания сеанса связи.
        Величина: 1.4 сек (одна единица регистра равна 0.1 сек)

        Остальные S-регистры доступны для чтения и записи, но модифицировать
        их  не рекомендуется, т.к. это будет приводить к нарушению нормальной
        работы модема.
```