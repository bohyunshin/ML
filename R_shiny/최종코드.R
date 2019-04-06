getwd()
setwd('c:/users/sbh0613/data')
#데이터 불러오기
bicycle.data <- read.csv('bicycle.csv',header=T)
wifi.data <- read.csv('wifi.csv',header=T)
work <- read.csv('work.csv',header=T)
ohdata<-read.csv('ohdata.csv',header=T)
dat <- read.csv("CPIDATA.csv",header=T)

attach(bicycle.data)
attach(wifi.data)
attach(work)
attach(ohdata)
attach(dat)

#year 지정하기
year.unem <- ohdata$year
year.cpi <- dat$year


#필요한 패키지 불러오기(install.packages가 되었다는 상황에서)
library(leaflet)
library(shiny)

#와이파이 아이콘 만들기
wifi.icon <- makeIcon(
		iconUrl = 'http://post.phinf.naver.net/MjAxNzEyMjdfMTEy/MDAxNTE0MzAxMTU1NjI0.eYHfuOPLcmJmO7GOYobRAjwQWWIF3KAoCdHf9GRKv-gg.LUySwJLOJbk5O59ArylPKqGjvyJhIYenQ4S7N9iczuUg.JPEG/ImmGUw2kkI6XNnOvt5-yECpBrtos.jpg',
		iconWidth = 31*215/230, iconHeight = 31,
		iconAnchorX= 31*215/230/2, iconAnchorY=16
)
#자전거 아이콘 만들기
b.icon <- makeIcon(
		iconUrl = 'http://post.phinf.naver.net/MjAxNzA3MTNfMjMy/MDAxNDk5OTM0OTk4NjU3.1vU1I5R0zlTyIeOw3FoBZG4dMdlYgt-oDLSEKsi_emEg.mOPjUvS1Cx2JeksdihSi4ldSN7gl-92PUH4ceCbQhWMg.JPEG/IwXRxRMTP1ciN5jUrBM4QMd5iA8I.jpg',
		iconWidth = 31*215/230, iconHeight = 31,
		iconAnchorX= 31*215/230/2, iconAnchorY=16
)

#알바 시급에 쓰일 df 만들기

df.work<-data.frame(lat=c(37.63665, 37.67302, 37.46189, 37.56840, 37.46722, 37.49440,
                          37.64957, 37.59858, 37.49698, 37.47056, 37.51331, 37.51457, 37.56162, 37.62077, 37.53433, 37.57215,
                          37.55185, 37.58390, 37.54870, 37.55776, 37.54793, 37.52184, 37.50222, 37.58139, 37.59852),
                    lng=c(127.01452,  127.03468, 126.90024, 126.89148, 126.94047, 126.85100, 127.07765, 127.08764, 127.05867,
                          127.02347, 127.11687, 126.90680, 127.00189, 126.92457, 126.98852, 126.93858, 127.08312, 126.97912,
                          127.05085, 126.81912, 127.14505, 126.85914, 126.94283, 127.05931, 127.01562),
                     id=c('강북구', '도봉구', '금천구',
'마포구', '관악구', '구로구', '노원구', '중랑구', '강남구', '서초구', '송파구', '영등포구', '중구', '은평구',
'용산구', '서대문구', '광진구', '종로구', '성동구', '강서구', '강동구', '양천구', '동작구', '동대문구', 
'성북구'))



ui <- navbarPage('미래로 대쉬하는 대학생이 대쉬오~',
  tags$head(
    tags$style(HTML("
      @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
      
      h1 {
        font-weight: bold;
	  font-size: 29px;
        color: #4d3a7d;
      }

    "))
  ),
#자전거
  tabPanel(


  headerPanel("Bicycle Depository"),
  sidebarPanel(
	helpText('ex) 서울특별시 구로구 00로, 대구광역시 서구 00로 (o)'),
	helpText('ex) 서울시 구로구 00로, 대구시 서구 00로 (x)'),
	helpText('검색 후에도 지도가 바뀌지 않으면 해당 데이터가 없거나 보관소가 존재하지 않는 것입니다.'),
      textInput("text.bi", label = h3("근처 위치를 입력하세요"), value = "도로명주소: ㅇㅇ시(띄어쓰기)ㅇㅇ구(띄어쓰기)ㅇㅇ로"),
      selectInput('air','공기주입기가 필요한가요?',choices=c('Y','N')),
	actionButton('search.bi',label='찾기')
  ),
  mainPanel(
    h3('자전거 보관소 위치'),
    h6('ex)xx개: 자전거 거치대가 xx개 있음'),
    leafletOutput("myplot.bi")
  )
  
),
#와이파이
  tabPanel(
  headerPanel('Wi-fi'),
  sidebarPanel(
	helpText('ex) 서울특별시 구로구 00로, 대구광역시 서구 00로 (o)'),
	helpText('ex) 서울시 구로구 00로, 대구시 서구 00로 (x)'),
	helpText('검색 후에도 지도가 바뀌지 않으면 해당 데이터가 없거나 와이파이가 존재하지 않는 것입니다.'),
      textInput("text.wifi", label = h3("근처 위치를 입력하세요."), value = "도로명주소: ㅇㅇ시(띄어쓰기)ㅇㅇ구(띄어쓰기)ㅇㅇ로"),
      actionButton('search.wifi',label='찾기')
  ),
  mainPanel(
    h3('Wi-fi Zone'),
    leafletOutput("myplot.wifi")
  )
),
#서울시 구별 평균 월세
  tabPanel(
  headerPanel('Room Price'),
sidebarPanel(
helpText("원하시는 서울 구를 클릭하세요."),
selectInput(inputId='gu', 
label='Choose a Gu:',
choices=c('강북구', '도봉구', '금천구', '마포구', '관악구', '구로구', '노원구', '중랑구', '강남구', '서초구', '송파구', '영등포구', '중구', '은평구',
             '용산구', '서대문구', '광진구', '종로구', '성동구', '강서구', '강동구', '양천구', '동작구', '동대문구', '성북구')),
textOutput('out1'),
actionButton('search.room',label='가격은?'),
verbatimTextOutput('caption'),
 tags$head(tags$style(HTML("
                            #caption {
                              font-size: 20px;
                            }
                            ")))
),
mainPanel(
leafletOutput("myplot.room")
 
)
),
#서울시 구별 시급
	tabPanel(
	headerPanel('Part-time Job'),
	sidebarPanel(
	
selectInput(inputId='guwork', 
label="원하시는 서울 구를 클릭하세요.",
choices=c('강북구', '도봉구', '금천구', '마포구', '관악구', '구로구', '노원구', '중랑구', '강남구', '서초구', '송파구', '영등포구', '중구', '은평구',
             '용산구', '서대문구', '광진구', '종로구', '성동구', '강서구', '강동구', '양천구', '동작구', '동대문구', '성북구')),

	uiOutput('myui')
	,

	actionButton('search.work',label='선택한 직종의 시급은?')

),



	mainPanel(
	h3('순서대로 최댓값 / 평균 / 최솟값'),
	leafletOutput('myplot.work')
)
),

#실업률 예측
	tabPanel(
	headerPanel('Unemployment'),
	sidebarPanel(
      radioButtons('radio.unem', label=h3('예측 모델 방법과 연도를 선택해주세요.'),
                   choices=list('prediction1(by Random Forest)', 'prediction2(by adaboost)', 'prediction3(by catboost)'),selected='prediction1(by Random Forest)'),
      selectInput('vertical.unem', 'Show vertical line in year(s):', choices=unique(year.unem), multiple=TRUE),
	checkboxInput('hor','Show horizontal axis', TRUE)
    ),
    mainPanel(
      h2('실업률 예측'),
      textOutput('text1'),
      plotOutput('lineChart.unem')
    )
),
#소득/물가지수
	tabPanel(
	headerPanel('Income/Cpi'),
	sidebarPanel(
      
      radioButtons("radio.cpi", label = h3("지표선택"),
                   choices = list("income", "CPI"),selected = "income"),
      
      selectInput("vertical.cpi","특정년도 점선표시", 
                  choices = unique(dat$year),multiple=TRUE
      )
    ),
  
    mainPanel(
      plotOutput("lineChart.cpi")
    )
)

)

#-----------------------------------------------


server <- function(input, output) {
 
#자전거
  locationInfo.bi <- eventReactive(input$search.bi,{
    data.frame(
    Name = bicycle.data$소재지도로명주소[
	grep(input$text.bi,bicycle.data$소재지도로명주소)[
	bicycle.data$공기주입기비치여부[grep(input$text.bi,bicycle.data$소재지도로명주소)] == input$air
	]
	],
    lat = bicycle.data$lat[
	grep(input$text.bi,bicycle.data$소재지도로명주소)[
	bicycle.data$공기주입기비치여부[grep(input$text.bi,bicycle.data$소재지도로명주소)] == input$air
	]
	],
    lng = bicycle.data$lon[
	grep(input$text.bi,bicycle.data$소재지도로명주소)[
	bicycle.data$공기주입기비치여부[grep(input$text.bi,bicycle.data$소재지도로명주소)] == input$air
	]
	],
    number = bicycle.data$설치대수[
	grep(input$text.bi,bicycle.data$소재지도로명주소)[
	bicycle.data$공기주입기비치여부[grep(input$text.bi,bicycle.data$소재지도로명주소)] == input$air
	]
	],
    loc = bicycle.data$자전거보관소명[
	grep(input$text.bi,bicycle.data$소재지도로명주소)[
	bicycle.data$공기주입기비치여부[grep(input$text.bi,bicycle.data$소재지도로명주소)] == input$air
	]
	]
  )
  },ignoreNULL=FALSE)
  
  output$value <- renderPrint({ input$text.bi })
  output$myplot.bi <- renderLeaflet({
    
    
    map.bi <- leaflet() %>%
      	addTiles() %>%
      	addMarkers(lat = locationInfo.bi()$lat,
		lng = locationInfo.bi()$lng,
		popup=as.character(paste0(locationInfo.bi()$Name,
		' / ',locationInfo.bi()$loc,
		' / ',paste(locationInfo.bi()$number,'개'))),
		icon = b.icon 
		)
    map.bi
  }) 
#와이파이
locationInfo.wifi <- eventReactive(input$search.wifi,{data.frame(
    Name = wifi.data$소재지도로명주소[grep(input$text.wifi,wifi.data$소재지도로명주소)],
    lat = wifi.data$lat[grep(input$text.wifi,wifi.data$소재지도로명주소)],
    lng = wifi.data$lon[grep(input$text.wifi,wifi.data$소재지도로명주소)],
    tel = wifi.data$관리기관전화번호[grep(input$text.wifi,wifi.data$소재지도로명주소)],
    service = wifi.data$서비스제공사명[grep(input$text.wifi,wifi.data$소재지도로명주소)],
    loc = wifi.data$설치장소명[grep(input$text.wifi,wifi.data$소재지도로명주소)]
  )
  },ignoreNULL=FALSE)
  
  output$value <- renderPrint({ input$text.wifi })
  output$myplot.wifi <- renderLeaflet({
    
    
    map.wifi <- leaflet() %>%
      	addTiles() %>%
      	addMarkers(lat = locationInfo.wifi()$lat,
		lng = locationInfo.wifi()$lng,
		popup=as.character(paste0(locationInfo.wifi()$Name,
		' / ',locationInfo.wifi()$loc,
		' / ',locationInfo.wifi()$tel,
		' / ',locationInfo.wifi()$service)),
		icon = wifi.icon 
		)
    map.wifi	
  })

  
#서울시 구별 평균 월세

df<-data.frame(lat=c(37.63665, 37.67302, 37.46189, 37.56840, 37.46722, 37.49440,
                          37.64957, 37.59858, 37.49698, 37.47056, 37.51331, 37.51457, 37.56162, 37.62077, 37.53433, 37.57215,
                          37.55185, 37.58390, 37.54870, 37.55776, 37.54793, 37.52184, 37.50222, 37.58139, 37.59852),
                    lng=c(127.01452,  127.03468, 126.90024, 126.89148, 126.94047, 126.85100, 127.07765, 127.08764, 127.05867,
                          127.02347, 127.11687, 126.90680, 127.00189, 126.92457, 126.98852, 126.93858, 127.08312, 126.97912,
                          127.05085, 126.81912, 127.14505, 126.85914, 126.94283, 127.05931, 127.01562),
                    z=c(35, 35, 35, 57, 38, 38, 36, 36, 56, 55, 53, 52, 53, 49, 49, 48, 48, 47, 46, 45, 45, 44, 40, 40, 47), id=c('강북구', '도봉구', '금천구',
'마포구', '관악구', '구로구', '노원구', '중랑구', '강남구', '서초구', '송파구', '영등포구', '중구', '은평구',
'용산구', '서대문구', '광진구', '종로구', '성동구', '강서구', '강동구', '양천구', '동작구', '동대문구', 
'성북구'))
     
     gu.information <- eventReactive(input$search.room,{
     df$z[df$id == input$gu]
}
)
     caption.gu <- eventReactive(input$search.room,{
	input$gu
}
)

     output$caption <- renderText({
		paste(caption.gu(),'의 평균 월세: ',gu.information(),'만원',sep='')
})

     output$myplot.room<-renderLeaflet({
         df %>%
         leaflet() %>%
         setView(lat=37.56162, lng=127.00189, zoom=11) %>%
         addTiles() %>%
         addCircles(weight=1, radius=df$z*60, color="black", fillColor="blue", stroke = TRUE, fillOpacity = 0.4)
     })
#서울시 구별 알바
output$gu.work <- renderPrint(input$guwork)

		observeEvent(input$search.work,{
		gu.infowork <- work[which((work$근무지역 == input$guwork & work$업직종 == input$gu.job)),]


		output$myplot.work <- renderLeaflet({
		map.work <- leaflet() %>%
				 addTiles() %>%
				 addMarkers(lat = df.work$lat[as.vector(df.work$id) == as.vector(gu.infowork$근무지역)],
				 lng = df.work$lng[as.vector(df.work$id) == as.vector(gu.infowork$근무지역)],
				 popup = as.character(paste0(gu.infowork$근무지역,
		'의 ',gu.infowork$업직종,
		': ',gu.infowork$max,
		' / ',gu.infowork$mean,
		' / ',gu.infowork$min))
				 )

		map.work
})
}
)
		output$myui <- renderUI({
		if(input$guwork == '강북구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '강북구'])	
		)
		} else if (input$guwork == '도봉구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '도봉구'])	
		)
		} else if (input$guwork == '금천구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '금천구'])	
		)
		} else if (input$guwork == '마포구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '마포구'])	
		)
		} else if (input$guwork == '관악구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '관악구'])	
		)
		} else if (input$guwork == '구로구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '구로구'])	
		)
		} else if (input$guwork == '노원구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '노원구'])	
		)
		} else if (input$guwork == '중랑구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '중랑구'])	
		)
		} else if (input$guwork == '강남구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '강남구'])	
		)
		} else if (input$guwork == '서초구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '서초구'])	
		)
		} else if (input$guwork == '송파구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '송파구'])	
		)
		} else if (input$guwork == '영등포구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '영등포구'])	
		)
		} else if (input$guwork == '중구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '중구'])	
		)
		} else if (input$guwork == '은평구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '은평구'])	
		)
		} else if (input$guwork == '용산구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '용산구'])	
		)
		} else if (input$guwork == '서대문구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '서대문구'])	
		)
		} else if (input$guwork == '광진구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '광진구'])	
		)
		} else if (input$guwork == '종로구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '종로구'])	
		)
		} else if (input$guwork == '성동구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '성동구'])	
		)
		} else if (input$guwork == '강서구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '강서구'])	
		)
		} else if (input$guwork == '강동구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '강동구'])	
		)
		} else if (input$guwork == '양천구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '양천구'])	
		)
		} else if (input$guwork == '동작구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '동작구'])	
		)
		} else if (input$guwork == '동대문구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '동대문구'])	
		)
		} else if (input$guwork == '성북구'){
		selectInput(inputId = 'gu.job', label = '원하시는 직종을 선택하세요.',
		choices = as.vector(work$업직종[work$근무지역 == '성북구'])	
		)
		}
})

#실업률
		output$text1<-renderText({
      paste('이 차트는 2020년까지 예측한 실업률을 보여주고 있습니다.', input$radio.unem)
    })
    output$lineChart.unem <- renderPlot({
      chartData<-switch(input$radio.unem,
                        'prediction1(by Random Forest)' = list(ohdata$rf,ohdata$zero1),
                        'prediction2(by adaboost)' = list(ohdata$ada,ohdata$zero2),
                        'prediction3(by catboost)' = list(ohdata$cat,ohdata$zero3)
      )
      
      chartTitle<-switch(input$radio.unem,
                         'prediction1(by Random Forest)' = '예상1(by Random Forest)',
                         'prediction2(by adaboost)' = '예상2(by adaboost)',
                         'prediction3(by catboost)' = '예상3(by catboost)'
                         #선택란에 한국어라 들어가면 shiny가 매핑을 못함
      ) 
      
      yrange<- c(-3,7)
      xrange<-range(year.unem)
      plot(xrange,yrange,type='n',xlab='',ylab='Unemployment rate (percent)', cex.lab=1.5,
           main=paste('실업률 지표', chartTitle))
      #year가 Year로 대문자로 쓰여져있었음
      lines(year.unem[1:39],chartData[[1]][1:39],col=c('aquamarine4'),lwd=3)
	lines(year.unem[39:41],chartData[[1]][39:41],col=c('firebrick3'),lty=2, lwd=5)
      lines(year.unem[2:42],na.omit(chartData[[2]]),col='black',lwd=3)
      abline(v=input$vertical.unem, lty=2)
	abline(h=c(1:6),lty=1,col='grey')
      if(input$hor){
	  abline(h=0)
	}
    }, height=600,width=800)
	


#가구소득/물가지수
	
	 output$lineChart.cpi <- renderPlot({  
    chartData.cpi <- switch(input$radio.cpi,
                        "CPI" = list(dat$cpi,dat$cpi_p),
                        "income" = list(dat$income,dat$income_p)
    )  
    
    chartTitle.cpi <- switch(input$radio.cpi,
                         "income" = "월평균 소득   (단위:백만)",
                         "CPI" = "소비자 물가지수  (단위:십)"
    )
    
    yrange.cpi <- c(-4,12)
    xrange.cpi <- range(year.cpi)
    plot(xrange.cpi,yrange.cpi,type="n",xlab="",ylab="",cex.lab=1.5,
         main=paste( chartTitle.cpi),
         sub=c("출처: 통계청"))
    lines(year.cpi,chartData.cpi[[1]],col="aquamarine4",lwd=3)
    lines(year.cpi[2:13],na.omit(chartData.cpi[[2]]),col="firebrick3",lwd=3)
    abline(v=input$vertical.cpi,lty=2)
    abline(h=c(1:10),lty=1,col='grey') 
    legend(2012,8,c("증감률(%)",'수치'), 
           col=c('firebrick3','aquamarine4'),pch=15,ncol=1,bty ="n",cex=1.1)
    if(input$hor){
	  abline(h=0)
	}
  
  },height = 500, width = 600)
  
}

shinyApp(ui=ui, server=server)

head(ohdata)



---------------------
#처음에는 dataframe의 각 컬럼을 eventreactive를 해서 데이터 프레임에 넣었는데 이렇게 하면
#문제점이 각 칼럼이 eventreactive되어서 dataframe으로 변환이 안되는 에러가 생김.
#그래서 아예 데이터 프레임 만들 때 안에다가 넣어버림. 따로 eventreactive하는 것이 아니라
#  lat.loc <- eventReactive(input$search,{wifi.data$lat[grep(input$text,wifi.data$소재지도로명주소)]
#  },ignoreNULL=FALSE)
  
#  lng.loc <- eventReactive(input$search,{wifi.data$lon[grep(input$text,wifi.data$소재지도로명주소)]
#  },ignoreNULL=FALSE)
# 이렇게 하면 dataframe으로 변환이 안된다고 에러가 뜸!
# 추가 사항으로 eventreactive로 만든 df의 칼럼을 server에서 가져오고 싶으면 df$col가 아니라 df()$col라고 해줘야 함
# 반드시 ()를 해줘야 함. 이거 안하면 object of type ‘closure’ is not subsettable이 에러 뜸.

