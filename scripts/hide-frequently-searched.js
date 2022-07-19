/*
  Copyright 2018-2022 Cargill Incorporated

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

const wrapperObserver = new MutationObserver(cb);

const resultsObserver = new MutationObserver(resultsCallback);

function cb(mutationsList, observer) {
  mutationsList.forEach( mutation => {
    let resultsWrapper = document.getElementsByClassName('gsc-results-wrapper-nooverlay');
    if (resultsWrapper.length) {
      resultsObserver.observe(
        resultsWrapper[0],
        { attributes: true }
      )
    }
  })
}

function resultsCallback(mutationsList, observer) {
  mutationsList.forEach( mutation => {
    if (mutation.attributeName === 'class') {
      if (mutation.target.classList.contains('gsc-results-wrapper-visible')) {
        document.getElementById("frequently-searched").style.visibility = "hidden";
      } else {
        document.getElementById("frequently-searched").style.visibility = "visible";
      }
    }
  })
}

wrapperObserver.observe(
  document.getElementById("search-wrapper"),
  { childList: true }
)
