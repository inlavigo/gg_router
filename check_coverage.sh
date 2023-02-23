
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

if  !([ -z ${1+x} ])
then
  open coverage/html/index.html
fi