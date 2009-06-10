HessianKit v.1.0.2

  Copyright 2008 Fredrik Olsson, Cocoway. All rights reserved.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License. 
  You may obtain a copy of the License at 

  http://www.apache.org/licenses/LICENSE-2.0 

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS, 
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

HessianKit is a Framework for Objective-C 2.0 to allow Mac OS X 10.5, and 
iPhone 2.0 applications to seamlessly communicate with hessian web services.
Hessian web services can be implemented using Java, .net and more.

    http://hessian.caucho.com/


HessianKit provided typed proxy objects to formward calls to, and and handle 
responses from any hessian web service, seamlessly just as if they where local
objects. HessianKit also provide functionality to automatically generate classes
for published value objects. Both web service proxies and value objects are 
defined as basic Objective-C Protocols.


The HessianKit project consist of several targets:
Documentation -
    Generated headercod documentation for the Mac OS X and iPhone API:s.
HessianKit -
    Generates a framework to be bundled with applications for Mac OS X 10.5 and
    later, includes documentation.
StaticHessianKit -
    Generates a static library to be linked with applications for iPhone OS 2.0
    and later.
MacTests -
    Executes unit tests for HessianKit target against Mac OS X 10.5 and later.
iPhoneTests -
    Executes unit tests for StaticHessianKit against iPhone OS 3.0 and later.
    Unit tests can not be executed against iPhone OS 2.x.
