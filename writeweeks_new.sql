create OR replace function casdev01.writeweeks (
	startYear integer,
	endYear integer
)
returns text AS $BODY$

var returnValue = "Success";
var startDate = new Date(startYear + '-1-1');
var endDate = new Date(endYear + '-12-31');
var janFirst = new Date(year + '-1-1');
var startOfWeek = new Date();
var endOfWeek = new Date();
var weekNumber = 0;
var firstWeekOfYear = [1, 2, 3]; /* conditions, that defines first week of year - this means 1=January 1st; 2=full week; 3=first four days, that are like a full week */
var firstDayOfWeek = [1, 2, 3, 4, 5, 6, 7]; /* all possible combinations for first day of the week */

/* definying variables for cycle, that generates years and weeks */
var weekNumber = 0;
var firstWeek = 1;
var year = startYear;
var Date = startDate;

for (year = startYear; year <= endYear; year++) {
	startDate = new Date(year + '-1-1');
	endDate = new Date(year + '-12-31');
	janFirst = new Date(year + '-1-1');

	for (Date = startDate; Date <= endDate; Date.setDate(Date.getDate() + 7)) {

		for (firstWeek = 1; firstWeek <= firstWeekOfYear.length; firstWeek++) {
			weekNumber = getWeekNumber (startDate, firstWeek);
			var daysOffset = 1 - (startDate.getDay() + 1); /* day of week starts in JS with 0 as a Sunday */

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
						weekNumber == 1;
					} else if (firstWeek == 2 && janFirst.getDay() == 0) {
						weekNumber == 1;
					} else {
						weekNumber == 0;
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

				var insertString = "INSERT INTO casdev01.period (dateFrom, dateThru, periodType,";
					insertString += "periodIndentifier, firstDayOfWeek, firstWeekOfYear, periodNumber, weeks, calendarYear)";
					insertString += "VALUES (\'" + formatDate(startOfWeek) +"\', \'" + formatDate(endOfWeek) + "\', \'week\'";
					insertString += ",\'week" + weekNumber + "/" + year + "\'";
					insertString += "," + day + "," + firstWeek + "," + weekNumber + ", 1, " + year + ")";
				plv8.execute(insertString);
			}

		}

	}

}

function getWeekNumber (Date, firstWeek) {
	
	var day = 1; /* defines 1st of January */
	if (firstWeek == 2) { /* first full week */
		day = 7; /* 7th day is always in in first full week */
	} else if

}

$BODY$
language plv8 volatile cost 100;
alter function casdev01.writeweeks (integer, integer) OWNER TO postgres;