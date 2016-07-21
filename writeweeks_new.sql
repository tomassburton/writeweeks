CREATE OR REPLACE FUNCTION casdev01.writeweeks(
    startyear integer,
    endyear integer
)
RETURNS text AS $BODY$

var returnValue = "Successfully generated";
var startDate = new Date(startyear + '-1-1');
var endDate = new Date(endyear + '-12-31');
var startOfWeek = new Date();
var endOfWeek = new Date();
var weekNumber = 0;
var firstWeekOfYear = [1, 2, 3]; /* conditions, that defines first week of year - this means 1=January 1st; 2=full week; 3=first four days, that are like a full week */
var firstDayOfWeek = [1, 2, 3, 4, 5, 6, 7]; /* all possible combinations for first day of the week */
var dayName = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/* definying variables for loop, that generates years and weeks */
var weekNumber = 0;

for (var year = startyear; year <= endyear; year++) {
	startDate = new Date (year + '-1-1');
	var janFirst = new Date (year + '-1-1');
	endDate = new Date (year + '-12-31');
	
	for (var date = startDate; date <= endDate; date.setDate(date.getDate() + 7)) {
		
		for (var firstWeek = 1; firstWeek <= firstWeekOfYear.length; firstWeek++) {
			weekNumber = getweekNumber(startDate, firstWeek);
			var daysOffset = 1 - (startDate.getDay() +1); /* day of week starts in JS with 0 as a Sunday */
			
			startOfWeek = new Date(startDate.getTime());
			startOfWeek.setDate(new Date(startOfWeek).getDate() + daysOffset);
			
			endOfWeek = new Date(startOfWeek.getTime());
			endOfWeek.setDate(new Date(endOfWeek).getDate() + 6);

			if (startOfWeek.getFullYear() != endOfWeek.getFullYear()) {
				
				if (year != endOfWeek.getFullYear()) {
					
					if (firstWeek == 2 || firstWeek == 3) {
						weekNumber = 0;
					} else if (firstWeek == 1 && endDate.getDay() < 3) {
						weekNumber = 0;
					}

				} else {
					if (firstWeek == 3) {
						weekNumber = 1;
					} else if (firstWeek == 1 && janFirst.getDay() <= 3) {
						weekNumber = 1;
					} else if (firstWeek == 2 && janFirst.getDay() == 0) {
						weekNumber = 1;
					} else {
						weekNumber = 0;
					}
				}

			}
			
			if (weekNumber == 0) {
				continue;
			}
				
			for (var day = 1; day <= firstDayOfWeek.length; day++) {
				
				var daysOffset = day - (startDate.getDay() + 1);
				
				startOfWeek = new Date(startDate.getTime());
				startOfWeek.setDate(new Date(startOfWeek).getDate() + daysOffset);
				
				endOfWeek = new Date(startOfWeek.getTime());
				endOfWeek.setDate(new Date(endOfWeek).getDate() + 6);

				var insertString = "INSERT INTO casdev01.period (datefrom, datethru, periodtype, ";
					insertString += "periodidentifier, firstdayofweek, firstweekofyear, periodnumber, weeks, calendaryear)";
					insertString += "VALUES (\'" + formatdate(startOfWeek) + "\', \'" + formatdate(endOfWeek) + "\',\'Week\'";
					insertString += ",\'Week" + weekNumber + "/" + year + "\'";
					insertString += "," + day + "," + firstWeek + "," + weekNumber + ", 1, " + year + ")";
				plv8.execute(insertString);
			}
		}
	}
}

function getweekNumber (date, firstWeek) {
	
	var day = 1; /* defines 1st of January */
	if (firstWeek == 2) { /* first full week */
		day = 7; /* 7th day is always in first full week */
	} else if (firstWeek == 1) {
		day = 4; /* 4th day is always in first full week */
	}

	var janFirst = new Date(date.getFullYear(), 0 , day);
	var weekNumber = Math.ceil((((date - janFirst) / 86400000) + janFirst.getDay() + 1) / 7);

	return weekNumber;

}

/*function getDayName (day, dayName) {
	var day = 1;
	var dayNameString = '';

	if (day == 1) {
		dayName = [0];
	} else if (day == 2) {
		dayName = [1];
	} else if (day == 3) {
		dayName = [2];
	} else if (day == 4) {
		dayName = [3];
	} else if (day == 5) {
		dayName = [4];
	} else if (day == 6) {
		dayName = [5];
	} else if (day == 7) {
		dayName = [6];
	}
	var dayNameString = dayName;
	return dayNameString;

}*/

function formatdate(d) {

	return d.getFullYear().toString() + '-' + (('0' + (d.getMonth() + 1)).slice(-2)) + '-' + (('0' + d.getDate()).slice(-2));

}

return returnValue;

$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;
ALTER FUNCTION casdev01.writeweeks(integer, integer) OWNER TO postgres;